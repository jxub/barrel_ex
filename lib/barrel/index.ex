defmodule Barrel.Index do
  @moduledoc """
  Provides facilities for working with indexes.
  Used mostly internally.

  Possibly reorganise into:

  Documents.fold/4
  Changes.fold/5
  Path.fold/5
  """

  @type barrel :: String.t()

  @type path :: String.t()

  @type fold_docs_opts :: %{
          include_deleted: boolean(),
          history: boolean(),
          # hexadecimal
          max_history: integer()
        }

  @type fold_changes_opts :: %{
          include_doc: boolean,
          with_history: boolean
        }

  @type fold_path_opts :: %{
          include_deleted: boolean(),
          history: boolean(),
          # hex
          max_history: integer()
        }

  @doc """
  Fold the barrel documents.
  """
  @spec fold_docs(barrel, fun, any, fold_docs_opts) :: {atom, list}
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
  @spec fold_changes(barrel, non_neg_integer, fun, any, fold_changes_opts) :: {atom, any}
  def fold_changes(barrel, since, fun, acc, opts) do
    with since <- since |> Integer.to_string() do
      case :barrel.fold_changes(barrel, since, fun, acc, opts) do
        :ok ->
          {:ok, nil}

        {:error, reason} ->
          {:error, reason}

        resp ->
          {:ok, resp}
      end
    end
  end

  @doc """
  Fold the barrel indexes.
  """
  @spec fold_path(barrel, path, fun, any, fold_path_opts) :: {atom, list}
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
