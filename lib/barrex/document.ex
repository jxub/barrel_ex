defmodule Barrex.Document do
  @moduledoc """
  Module to interact with barrel documents and its
  creation, deletion, updates...
  """

  alias Barrex.Index

  @type barrel :: String.t()

  @type doc :: map()

  @type doc_id :: String.t()

  @type rev_id :: String.t()

  @type doc_or_docs_rev_id :: [doc | {doc_id | rev_id}]

  @type status :: :ok | :error

  @type fetch_one_opts :: %{
          history: boolean(),
          max_history: non_neg_integer(),
          rev: rev_id(),
          ancestors: [rev_id()]
        }

  @type fetch_one_result :: {
          status,
          map() | :not_found | term()
        }

  @type fetch_opts :: %{
          history: boolean(),
          max_history: non_neg_integer(),
          rev: rev_id(),
          ancestors: [rev_id()],
          timeout: non_neg_integer()
        }

  @type fetch_results :: {
          status,
          [fetch_one_result] | :timeout
        }

  @type doc_error :: {:conflict, :revision_conflict | :doc_exists}

  @type db_error :: :db_not_found

  @type save_opts :: %{
          all_or_nothing: boolean()
        }

  @type save_one_result ::
          {:ok, doc_id, rev_id}
          | {:error, doc_error}
          | {:error, db_error}

  @type save_results :: {
          :ok,
          [save_one_result]
        }

  @type delete_one_result ::
          {:ok, doc_id, rev_id}
          | {:error, doc_error}
          | {:error, db_error}

  @type delete_results :: {
          :ok,
          [delete_one_result]
        }

  @type purge_one_result :: :ok | {:error, term()}

  @type purge_results :: {
          :ok,
          [purge_one_result]
        }

  @doc """
  Get all document id's in a barrel.
  """
  def ids(barrel) do
    Index.fold_docs(barrel, fn doc, acc -> {:ok, [doc["id"] | acc]} end, [], %{})
  end

  @doc """
  Lookup one doc by its `doc_id` with aditional options.
  """
  @spec fetch_one(barrel, doc_id, fetch_one_opts) :: fetch_one_result
  def fetch_one(barrel, doc_id, opts \\ %{}) do
    case :barrel.fetch_doc(barrel, doc_id, opts) do
      {:ok, doc} when is_map(doc) ->
        {:ok, doc}

      {:error, :not_found} ->
        {:error, :not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Lookup multiple docs by their `doc_ids`. Options can be applied.
  """
  @spec fetch(barrel, [doc_id], fetch_opts) :: fetch_results
  def fetch(barrel, doc_ids, opts \\ %{}) do
    case :barrel.fetch_docs(barrel, doc_ids, opts) do
      {:ok, docs} when is_list(docs) ->
        # one/many/all documents may still be missing
        {:ok, docs}

      {:error, :not_found} ->
        # database doesn't exist
        {:error, :not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Create or replace a doc.
  Barrel will try to create a document if no `rev'
  property is passed to the document if the `_deleted'
  property is given the doc will be deleted.

  conflict rules:
  - if the user try to create a doc that already exists,
    a conflict will be returned, if the doc is not deleted
  - if the user try to update with a revision that
    doesn't correspond to a leaf of the revision tree, a
    conflict will be returned as well
  - if the user try to replace a doc that has been deleted,
    a not_found error will be returned
  """
  @spec save_one(barrel, doc) :: save_one_result
  def save_one(barrel, doc) do
    case :barrel.save_doc(barrel, doc) do
      {:ok, doc_id, rev_id} ->
        {:ok, doc_id, rev_id}

      {:error, :db_not_found} ->
        {:error, :db_not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Create or replace multiple documents. Also, options are possible.
  """
  @spec save(barrel, [doc], save_opts) :: save_results
  def save(barrel, docs, options \\ %{}) do
    # returns a list, pattern match makes little sense
    :barrel.save_docs(barrel, docs, options)
  end

  @doc """
  Delete a document, it doesn't delete the document
  from the filesystem but instead create a tombstone
  that allows barrel to replicate a deletion.
  """
  @spec delete_one(barrel, doc_id, rev_id) :: delete_one_result
  def delete_one(barrel, doc_id, rev_id) do
    case :barrel.delete_doc(barrel, doc_id, rev_id) do
      {:ok, doc_id, rev_id} ->
        {:ok, doc_id, rev_id}

      {:error, doc_error} ->
        {:error, doc_error}

      {:error, :db_not_found} ->
        {:error, doc_id, :db_not_found}
    end
  end

  @doc """
  Delete multiple documents as specified in the 
  list of document revision ids or documents themselves.
  Allows barrel to replicate all deletions.
  """
  @spec delete(barrel, doc_or_docs_rev_id) :: delete_results
  def delete(barrel, doc_or_docs_rev_id) do
    # returns a list, pattern match makes little sense
    :barrel.delete_docs(barrel, doc_or_docs_rev_id)
  end

  @doc """
  Delete a document from the filesystem.
  This deletes completely the document locally.
  The deletion won't be replicated and
  will not crete an event.
  """
  @spec purge_one(barrel, doc_id) :: purge_one_result
  def purge_one(barrel, doc_id) do
    case :barrel.purge_doc(barrel, doc_id) do
      :ok ->
        {:ok, doc_id}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Same as purge, but for multiple documents.
  """
  @spec purge(barrel, [doc_id]) :: purge_results
  def purge(barrel, doc_ids) do
    with purge_results <-
           doc_ids
           |> Enum.map(fn doc_id ->
             purge_one(barrel, doc_id)
           end) do
      {:ok, purge_results}
    end
  end

  ## LOCAL OPERATIONS: DEPRECATED

  @doc """
  Create or replace a local document.
  A local document has no revision and is not
  replicated. It's generally intented for
  local usage. It's used by the
  replication to store its state?

  TODO: deprecated
  """
  @spec save_local(String.t(), String.t(), map) :: {atom, String.t() | atom | term}
  def save_local(barrel, doc_id, doc) do
    case :barrel.save_local_doc(barrel, doc_id, doc) do
      :ok ->
        {:ok, doc_id}

      {:error, :db_not_found} ->
        {:error, :db_not_found}

      {:error, reason} ->
        {:error, reason}

      _ ->
        raise "unhandled message"
    end
  end

  @doc """
  Delete a local document.

  TODO: deprecated
  """
  @spec delete_local(String.t(), String.t()) :: {atom, String.t() | atom | term}
  def delete_local(barrel, doc_id) do
    case :barrel.delete_local_doc(barrel, doc_id) do
      :ok ->
        {:ok, doc_id}

      {:error, :db_not_found} ->
        {:error, :db_not_found}

      {:error, reason} ->
        {:error, reason}

      _ ->
        raise "unhandled message"
    end
  end

  @doc """
  Fetch a local document.

  TODO: deprecated
  """
  @spec get_local(String.t(), String.t()) :: {atom, map | atom | term}
  def get_local(barrel, doc_id) do
    case :barrel.get_local_doc(barrel, doc_id) do
      {:ok, doc} when is_map(doc) ->
        {:ok, doc}

      {:error, :db_not_found} ->
        {:error, :db_not_found}

      {:error, reason} ->
        {:error, reason}

      _ ->
        raise "unhandled message"
    end
  end
end
