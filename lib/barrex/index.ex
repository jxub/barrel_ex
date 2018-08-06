defmodule Barrex.Index do
  @moduledoc """
  Provides facilities for working with indexes.

  TODO: reorganise into:

  Documents.fold/4
  Changes.fold/5
  Path.fold/5
  """

  @doc """
  Fold the barrel documents.
  TODO: check return spec
  """
  @spec fold_docs(String.t(), fun, any, map) :: {atom, list}
  def fold_docs(barrel, fun, acc, opts) do
    case :barrel.fold_docs(barrel, fun, acc, opts) do
      :ok ->
        {:ok, nil}

      {:error, reason} ->
        {:error, reason}

      resp ->
        {:ok, resp}
    end
  end

  @doc """
  Fold the barrel changes.
  """
  @spec fold_changes(String.t(), non_neg_integer, fun, any, map) :: any
  def fold_changes(barrel, since, fun, acc, opts) do
    case :barrel.fold_changes(barrel, since, fun, acc, opts) do
      :ok ->
        {:ok, nil}

      {:error, reason} ->
        {:error, reason}

      resp ->
        {:ok, resp}
    end
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
