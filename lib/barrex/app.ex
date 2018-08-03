defmodule Barrex.App do
  use Application

  def start(_type, opts) do
    IO.inspect(parse_conn_opts(opts))
    children = [
      {Barrex.Connection, parse_conn_opts(opts)}
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
