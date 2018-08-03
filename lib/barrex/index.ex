defmodule Barrex.Index do
  @moduledoc """
  Provides facilities for working with indexes.
  """

  @doc """
  Fold the barrel documents.
  TODO: check return spec
  """
  @spec fold_docs(String.t(), String.t(), fun, any, map) :: {atom, list}
  def fold_docs(barrel, path, fun, acc, opts) do
    case :barrel.fold_docs(barrel, path, fun, acc, opts) do
      :ok ->
        {:ok, nil}

      {:error, reason} ->
        {:error, reason}

      resp ->
        {:ok, resp}
    end
  end

  @doc """
  Get all document id's in a barrel.
  TODO: move to documents?
  """
  def ids(barrel) do
    fold_docs(barrel, "/id", fn doc, acc -> {:ok, [doc["id"] | acc]} end, [], %{})
  end

  @doc """
  Fold the barrel indexes.
  """
  @spec fold_path(String.t(), String.t(), fun, any, map) :: {atom, list}
  def fold_path(barrel, path, fun, acc, opts) do
    case :barrel.fold_path(barrel, path, fun, acc, opts) do
      :ok ->
        {:ok, nil}

      {:error, reason} ->
        {:error, reason}

      resp ->
        {:ok, resp}
    end
  end
end
