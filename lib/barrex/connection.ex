defmodule Barrex.Connection do
  use GenServer

  require Logger

  def start_link(opts) do
    vm_opts =
      opts
      |> Keyword.take([:debug, :name, :timeout, :spawn_opt])

    GenServer.start_link(__MODULE__, opts, vm_opts)
  end

  defmodule Node do
    defstruct state: nil, node: nil, name: nil
  end

  defmodule State do
    # TODO: add multiple remotes
    defstruct client: %Node{},
              remote: %Node{},
              errors: []
  end

  def name do
    case Process.info() do
      nil ->
        raise "error"

      _ ->
        raise "not implemented"
    end
  end

  @impl true
  def init(opts) do
    {:ok, remote} =
      opts
      |> register_local!()
      |> parse_node!()
      |> start_slave!()

    # TODO: doublecheck and ask about process regsistry
    # possibly no need to store state apart from Process dict
    # ask benoit about communication
    with Process.register(self(), :client) do
      state = %State{
        client: %{
          state: :alive,
          pname: :client
        }
      }

      {:ok, state}
    end

    {:error, %{errors: ["couldn't register root process"]}}
  end

  def register_local!(opts) do
    with local <- Map.get(opts, :local, "primary@127.0.0.1") do
      {:ok, pid} = :net_kernel.start([local])
      Process.register(pid, :local)
    end

    opts
  end

  @impl true
  def handle_call(:status, state) do
    with remote <- Map.fetch!(state, :remote),
         local <- Map.fetch!(state, :local),
         lookup_pid <- :rpc.call(remote, :erlang, :whereis, [local]) do
      case Process.info(lookup_pid) do
        nil ->
          state = state |> Map.put(:remote, :down)
          {:reply, :down, state}

        _ ->
          state = state |> Map.put(:remote, :alive)
          {:reply, :alive, state}
      end
    end
  end

  @spec parse_node!(map) :: String.t()
  def parse_node!(opts) do
    with node <- Map.get(opts, :node),
         url <- Map.get(opts, :url),
         cip <- String.to_charlist(ip),
         {:ok, addr} <- :inet.parse_address(cip) do
      format_node(node, url)
    end
  end

  @spec unparse_node(node) :: {charlist, atom}
  def unparse_node(node) do
    {node, url} = node |> String.split("@") |> List.to_tuple()

    {String.to_charlist(node), String.to_atom(url)}
  end

  @spec format_node(String.t, String.t) :: atom
  defp format_node(node \\ "nonode", url \\ "nohost") do
    "#{node}@#{host}"
    |> String.to_atom()
  end

  @spec allow_boot(String.t) :: atom
  defp allow_boot(host) do
    with h <- String.to_charlist(host),
      {:ok, ip} <- :inet.parse_address(h) do
        :erl_boot_server.add_slave(ip)

        :ok
      else
        _ ->
          :error
      end
  end

  @spec start_slave!(node) :: node
  def start_slave!(barrel_node) do
    with {node, host} <- unparse_node(barrel_node),
          :ok <- allow_boot(host2)
            do
      {:ok, remote_node} = :slave.start(host, node)

      with :pong <- Node.ping(remote_node),
           path <- barrel_path(),
           true <- :rpc.call(remote_node, :code, :set_path, [path]) do
        {:ok, _res} = :rpc.call(remote_node, Application, :ensure_all_started, [:barrel])

        {:ok, _res2} =
          :rpc.call(remote_node, :barrel_store_sup, :start_store, [
            :default,
            :barrel_memory_storage,
            %{}
          ])

        Logger.info("Connection to #{remote_node} established")

        {:ok, remote_node}
      else
        _ ->
          Logger.error("Couldn't connect to the created slave")
          {:error, nil}
      end
    else
      _ ->
        Logger.error("Couldn't start slave")
        {:error, nil}
    end
  end

  defp barrel_path() do
    with all_code <- :code.get_path() do
      all_code
      |> Enum.filter(fn path ->
        String.contains?(path, "rebar3")
      end)
    end
  end
end
