defmodule Barrex.Document do
  
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
  @spec save(String.t(), map()) :: {atom(), String.t(), String.t()} | 
  def save(barrel, doc) do
    :barrel.save_doc(barrel, doc)
  end

  @doc """
  Delete a document, it doesn't delete the document
  from the filesystem but instead create a tombstone
  that allows barrel to replicate a deletion.
  """
  def delete(barrel, doc_id, rev_id) do
    :barrel.delete_doc(barrel, doc_id, rev_id)
  end

  def purge(barrel, doc_id) do
    nil
  end

  def save/2 do
    nil
  end

  def delete/2 do
    nil
  end

  def save_local/3 do
    nil
  end

  def delete_local/2 do
    nil
  end

  def get_local/2 do
    nil
  end
end