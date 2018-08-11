defmodule Barrel.Connection do
  use GenServer

  @max_reconnect_interval 1_000
  @connect_timeout 1_000_000
  @reconnect_interval 100

  @address "127.0.0.1"
  @port 6000

  defmodule State do
    @type t :: %__MODULE__{
            address: String.t(),
            port: integer(),
            auto_reconnect: boolean(),
            queue_if_disconnected: boolean(),
            sock: any(),
            active: any(),
            queue: tuple(),
            connects: integer(),
            failed: list(),
            connect_timeout: integer(),
            reconnect_interval: integer()
          }

    defstruct [
      :address,
      :port,
      :auto_reconnect,
      :queue_if_disconnected,
      :sock,
      :active,
      :queue,
      :connects,
      :failed,
      :connect_timeout,
      :reconnect_interval
    ]
  end

  defmodule Request do
    defstruct [:ref, :msg, :from, :ctx, :timeout, :tref]
  end

  @doc """
  Usage:

  {:ok, conn} = Barrel.Connection.start_link("127.0.0.1", 6000)
  """

  @spec start_link(list) :: any
  def start_link(opts) do
    start_link(@address, @port, %{})
  end

  @spec start_link(String.t(), integer, map | none) :: {atom, any}
  def start_link(address \\ @address, port \\ @port, options \\ %{}) do
    with args <- Map.new(address: address, port: port, options: options) do
      GenServer.start_link(__MODULE__, args)
    end
  end

  def init(opts) when is_map(opts) do
    with state <- opts |> parse_state() do
      case state.auto_reconnect |> IO.inspect() do
        true ->
          send(self(), :reconnect)

        false ->
          case connect(state) do
            {:error, reason} ->
              {:stop, {:tcp, reason}}

            {:ok, state} ->
              {:ok, state}
          end
      end
    end
  end

  def handle_info(:reconnect, %State{} = state) do
    case connect(state) do
      {:ok, new_state} ->
        {:noreply, deque_request(new_state)}

      {:error, reason} ->
        with new_state <- nil do
          nil
        end
    end
  end

  # TODO: implement also for other transports (GRPC)
  defp connect(%State{sock: nil} = state) do
    with address <- state |> Map.fetch!(:address) |> String.to_charlist(),
         opts <- [:binary, {:active, :once}, {:packet, 4}, {:header, 1}] |> IO.inspect(),
         connects <- Map.fetch!(state, :connects) |> IO.inspect() do
      case :gen_tcp.connect(address, state.port, opts, state.connect_timeout) do
        {:ok, sock} ->
          with state <-
                 Map.merge(state, %{sock: sock, connects: connects + 1, reconnect_interval: 100}) do
            {:ok, state}
          end

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  # TODO: implement also for other transports (GRPC)
  defp disconnect(%State{} = state) do
    case state.active do
      nil ->
        :ok

      request ->
        send_caller({:error, :disconnected}, request)
    end

    if not state.sock do
      :gen_tcp.close(state.sock)
    end

    with state <- state |> Map.put(sock, nil) |> Map.put(active, nil) do
      case state.auto_reconnect do
        true ->
          :erlang.send_after(state.reconnect_interval, self(), :reconnect)
          {:noreply, increase_reconnect_interval(state)}

        false ->
          {:stop, :disconnected, state}
      end
    end
  end

  defp increase_reconnect_interval(%State{} = state) do
    case state.reconnect_interval do
      interval when interval < @max_reconnect_interval ->
        new_interval = Enum.min([interval * 2, @max_reconnect_interval])
        Map.put(state, :reconnect_interval, new_interval)

        state

      _ ->
        state
    end
  end

  defp parse_state(opts) do
    with address <- Map.get(opts, :address, @address) |> IO.inspect(),
         port <- Map.get(opts, :port, @port) |> IO.inspect(),
         options <- Map.get(opts, :options, %{}),
         auto_reconnect = Map.get(options, :auto_reconnect, false),
         queue_if_disconnected <- Map.get(options, :queue_if_disconnected, false),
         connect_timeout <- Map.get(options, :connect_timeout, @connect_timeout),
         reconnect_interval <- Map.get(options, :reconnect_interval, @reconnect_interval) do
      %State{
        address: address,
        port: port,
        auto_reconnect: auto_reconnect,
        queue_if_disconnected: queue_if_disconnected,
        sock: nil,
        active: nil,
        queue: :queue.new(),
        connects: 0,
        failed: [],
        connect_timeout: connect_timeout,
        reconnect_interval: reconnect_interval
      }
    end
  end

  defp deque_request(state) do
    case :queue.out(state.queue) do
      {:empty, _} ->
        state

      {{:value, request}, queue2} ->
        send_request(request, Map.merge(state, %{queue: queue2}))
    end
  end

  defp send_caller(message, %Request{ctx: {req_id, client}, from: nil} = request) do
    send(client, {req_id, message})

    request
  end

  defp send_caller(message, %Request{from: from} = request) when not is_nil(from) do
    GenServer.reply(from, message)

    request
    |> Map.put(:from, nil)

    request
  end

  defp send_request(request, %State{active: nil} = state) do
    with msg <- encode(request) do
      case :gen_tcp.send(state.sock, msg) do
        :ok ->
          with state <- state |> Map.merge(%{active: request}) do
            request
            |> after_send(state)
            |> maybe_reply()
          end

        {:error, :closed} ->
          state
          |> Map.fetch(:sock)
          |> :gen_tcp.close()

          with state <- state |> Map.merge(%{active: request}) do
            request
            |> maybe_enqueue_and_reconnect(state)
          end
      end
    end
  end

  defp encode(_request) do
    raise "not implemented"
  end

  defp maybe_reply({:noreply, state}), do: state

  defp maybe_reply({:reply, reply, state}) do
    with state <- Map.fetch!(state, :active),
         request <- reply |> send_caller(state) do
      state
      |> Map.merge(%{active: request})
    end
  end

  defp maybe_enqueue_and_reconnect(request, state) do
    nil
  end

  defp after_send(_bla, _ble) do
    nil
  end
end
