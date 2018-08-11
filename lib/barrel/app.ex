defmodule Barrel.App do
  use Application

  alias Barrel.{
    Connection,
    DatabaseInfo
  }

  def start(_type, opts) do
    IO.inspect(parse_conn_opts(opts))

    children = [
      # {Connection, parse_conn_opts(opts)},
      {DatabaseInfo, name: DatabaseInfo}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp parse_conn_opts(opts) do
    with {address, opts} <- opts |> Keyword.pop(:address),
         {port, opts} <- opts |> Keyword.pop(:port),
         opts <- opts |> Enum.into(%{}) do
      [address, port, opts]
    end
  end
end
