defmodule Barrex.Document do
  @moduledoc """
  Module to interact with barrel documents and its
  creation, deletion, updates...
  """
  
  @doc """
  Lookup a doc by its `doc_id`.
  """
  @spec fetch(String.t(), String.t(), map()) :: {atom(), map() | atom()}
  def fetch(barrel, doc_id, opts \\ %{}) do
    :barrel.fetch_doc(barrel, doc_id, opts)
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
  @spec save_one(String.t(), map()) :: {atom(), String.t(), String.t()} | 
  def save_one(barrel, doc) do
    :barrel.save_doc(barrel, doc)
  end

  @doc """
  Delete a document, it doesn't delete the document
  from the filesystem but instead create a tombstone
  that allows barrel to replicate a deletion.
  """
  def delete_one(barrel, doc_id, rev_id) do
    :barrel.delete_doc(barrel, doc_id, rev_id)
  end

  @doc """
  Selete a document from the filesystem.
  This deletes completely the document locally.
  The deletion won't be replicated and
  will not crete an event.
  """
  def purge(barrel, doc_id) do
    :barrel.purge_doc(barrel, doc_id)
  end

  @doc """
  Like save_doc but create or replace multiple docs at once.
  """
  @spec save(String(), list(map)) :: list(any())
  def save(barrel, docs) do
    :barrel.save_docs(barrel, docs)
  end

  @doc """
  Delete multiple docs. `docs` can be a list
  of `doc_id` or `rev_id`
  """
  @spec delete(String.t(), list(String.t())) :: list(any())
  def delete(barrel, docs) do
    :barrel.delete_docs(name, docs)
  end

  @doc """
  Create or replace a local document.
  A local document has no revision and is not
  replicated. It's generally intented for
  local usage. It's used by the
  replication to store its state?
  """
  def save_local(barrel, doc_id, doc) do
    :barrel.save_local_doc(name, doc_id, doc)
  end

  @doc """
  Delete a local document.
  """
  def delete_local(name, doc_id) do
    :barrel.delete_local_doc(name, doc_id)
  end

  @doc """
  Fetch a local document.
  """
  def get_local(name, doc_id) do
    :barrel.get_local_doc(name, doc_id)
  end
end