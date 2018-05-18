defmodule BarrelEx.Request do
  use HTTPoison.Base

  @endpoint Application.get_env(:barrel_ex, :database_url)

  def process_url(url) do
    @endpoint <> url
  end

  def process_request_body(body) do
    Poison.encode!(body)
  end

  def process_response_body(body) do
    body
    |> Poison.decode!()
    # |> atomize()
  end

  defp atomize(body) when is_list(body) do
    for e <- body, do: atomize(e)
  end

  defp atomize(body) when is_map(body) do
    Enum.map(body, fn n -> n end)
  end

  defp atomize(body) when is_binary(body) do
    String.to_atom(body)
  end

  defp atomize(body) when is_integer(body) do
    Integer.to_string(body)
  end

  defp atomize(body) when is_float(body) do
    Float.to_string(body)
  end

  defp atomize(body) when is_atom(body) do
    body
  end

  defp atomize(k, v) when is_map(v) do
    {atomize(k), atomize(v)}
  end

  defp atomize(k, v) when is_list(v) do
    {atomize(k), v}
  end
end
