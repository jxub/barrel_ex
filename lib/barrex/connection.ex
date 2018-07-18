defmodule Barrex.Connection do
  use GenServer

  @max_reconnect_interval 1_000

  defmodule State do
    defstruct address: nil,
              port: nil,
              auto_reconnect: false,
              queue_if_disconnected: false,
              sock: nil,
              active: nil,
              queue: nil,
              connects: 0,
              failed: [],
              connect_timeout: 100_000_000,
              reconnect_interval: 100
  end

  defmodule Request do
    defstruct ref: nil,
              msg: nil,
              from: nil,
              ctx: nil,
              timeout: nil,
              tref: nil
  end

  def start_link(address, port, options \\ []) do
    with args <- %{address: address, port: port, options: options} do
      GenServer.start_link(__MODULE__, args)
    end
  end

  def init(opts) when is_map(opts) do
    with address <- Map.(opts, :address, "127.0.0.1"),
         port <- Map.get(opts, :port, 6000),
         options <- Map.get(opts, :options, []),
         state <- options |> parse_state() do
      case state.auto_reconnect do
        true ->
          send(self(), :reconnect)

        false ->
          case connect(state) do
            {:error, reason} ->
              {:stop, {:tcp, reason}}

            {:ok, state} ->
              :ok
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
  defp connect(%State{} = state) when is_nil(state.sock) do
    with opts <- [:binary, {:active, :once}, {:packet, 4}, {:header, 1}],
         connects <- Map.fetch!(state, :connects) do
      case :gen_tcp.connect(state.address, state.port, opts, state.connect_timeout) do
        {:ok, sock} ->
          {:ok, %State{sock: sock, connects: connects + 1, reconnect_interval: 100}}

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
    nil
  end

  defp send_caller(message, %Request{ctx: {req_id, client}, from: nil} = request) do
    send(client, {req_id, message})

    request
  end

  defp send_caller(message, %Request{from: from} = request) when not is_nil(from) do
    GenServer.reply(from, message)
    request |> Map.put(:from, nil)

    request
  end
end
