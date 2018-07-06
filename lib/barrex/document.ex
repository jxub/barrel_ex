defmodule Barrex.Document do
  @moduledoc """
  Module to interact with barrel documents and its
  creation, deletion, updates...
  """

  @doc """
  Lookup a doc by its `doc_id`.
  """
  @spec fetch(String.t(), String.t(), map) :: {atom, map | atom}
  def fetch(barrel, doc_id, opts \\ %{}) do
    case :barrel.fetch_doc(barrel, doc_id, opts) do
      {:ok, doc} when is_map(doc) ->
        {:ok, doc}

      {:error, :not_found} ->
        {:error, :not_found}

      {:error, reason} ->
        {:error, reason}

      _ ->
        raise "unhandled message"
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
  @spec save_one(String.t(), map) :: {atom, String.t(), String.t()}
  def save_one(barrel, doc) do
    case :barrel.save_doc(barrel, doc) do
      {:ok, doc_id, rev_id} ->
        {:ok, doc_id, rev_id}

      {:error, {doc_error, doc_id}} ->
        {:error, doc_id, doc_err}

      {:error, :db_not_found} ->
        {:error, doc_id, :db_not_found}

      _ ->
        raise "unhandled message"
    end
  end

  @doc """
  Delete a document, it doesn't delete the document
  from the filesystem but instead create a tombstone
  that allows barrel to replicate a deletion.
  """
  @spec delete_one(String.t(), String.t(), String.t()) :: {atom, String.t(), String.t() | atom}
  def delete_one(barrel, doc_id, rev_id) do
    case :barrel.delete_doc(barrel, doc_id, rev_id) do
      {:ok, doc_id, rev_id} ->
        {:ok, doc_id, rev_id}

      {:error, {doc_error, doc_id}} ->
        {:error, doc_id, doc_err}

      {:error, :db_not_found} ->
        {:error, doc_id, :db_not_found}

      _ ->
        raise "unhandled message"
    end
  end

  @doc """
  Selete a document from the filesystem.
  This deletes completely the document locally.
  The deletion won't be replicated and
  will not crete an event.
  """
  @spec purge(String.t(), String.t()) :: {atom, String.t() | atom}
  def purge(barrel, doc_id) do
    case :barrel.purge_doc(barrel, doc_id) do
      :ok ->
        {:ok, doc_id}

      {:error, reason} ->
        {:error, reason}

      _ ->
        raise "unhandled message"
    end
  end

  @doc """
  Like save_doc but create or replace multiple docs at once.
  """
  @spec save(String.t(), list(map)) :: list(any)
  def save(barrel, docs) do
    case :barrel.save_docs(barrel, docs) do
      {:ok, doc_id, rev_id} ->
        {:ok, doc_id, rev_id}

      {:error, {doc_error, doc_id}} ->
        {:error, doc_id, doc_err}

      {:error, :db_not_found} ->
        {:error, doc_id, :db_not_found}

      _ ->
        raise "unhandled message"
    end
  end

  @doc """
  Delete multiple docs. `docs` can be a list
  of `doc_id` or `rev_id`
  """
  @spec delete(String.t(), list(String.t())) :: list(any)
  def delete(barrel, docs) do
    case :barrel.delete_docs(barrel, docs) do
      {:ok, doc_id, rev_id} ->
        {:ok, doc_id, rev_id}

      {:error, {doc_error, doc_id}} ->
        {:error, doc_id, doc_err}

      {:error, :db_not_found} ->
        {:error, doc_id, :db_not_found}

      _ ->
        raise "unhandled message"
    end
  end

  @doc """
  Create or replace a local document.
  A local document has no revision and is not
  replicated. It's generally intented for
  local usage. It's used by the
  replication to store its state?
  """
  @spec save_local(String.t(), String.t(), map) :: {atom, String.t() | atom}
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
  """
  @spec delete_local(String.t(), String.t()) :: {atom, String.t() | atom}
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
  """
  @spec get_local(String.t(), String.t()) :: {atom, map | atom}
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
