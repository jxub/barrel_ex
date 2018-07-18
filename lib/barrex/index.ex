defmodule Barrex.Index do
  @moduledoc """
  Provides facilities for working with indexes.
  """

  @doc """
  Query the barrel indexes.

  TODO: try to track down the :barrel.query return values.
  """
  @spec query(String.t(), String.t(), fun, any, map) :: {atom, list}
  def query(barrel, path, fun, acc, opts) do
    case :barrel.query(barrel, path, fun, acc, opts) do
      :ok ->
        {:ok, nil}

      {:error, reason} ->
        {:error, reason}

      resp ->
        {:ok, resp}
    end
  end

  def ids(barrel) do
    query(barrel, "/id", fn doc, acc -> {:ok, [doc["id"] | acc]} end, [], %{})
  end
end
