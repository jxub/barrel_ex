defmodule BarrelEx.Sysdoc do
  @moduledoc """
  Utilities for working with system documents.
  Usually not to be used, nevertheless I'll
  expose the API as I don't want to limit
  the BarrelEx client.
  """
  alias BarrelEx.Request

  @doc """
  Get a system document and the response status.
  """
  @spec get(String.t(), String.t()) :: {atom(), map()}
  def get(db, doc_id) do
    with url = make_url(db, doc_id) do
      Request.get(url)
    end
  end

  @doc """
  Get a system document.
  """
  @spec get!(String.t(), String.t()) :: map()
  def get!(db, doc_id) do
    with url = make_url(db, doc_id) do
      Request.get!(url)
    end
  end

  @doc """
  Update a system document with returning
  the response status.
  """
  @spec put(String.t(), String.t()) :: {atom(), map()}
  def put(db, doc_id) do
    with url = make_url(db, doc_id) do
      Request.put(url)
    end
  end

  @doc """
  Update a system document.
  """
  @spec put!(String.t(), String.t()) :: map()
  def put!(db, doc_id) do
    with url = make_url(db, doc_id) do
      Request.put!(url)
    end
  end

  defp make_url(db, doc_id) when is_bitstring(doc_id) do
    "dbs/" <> db <> "/system/" <> doc_id
  end

  defp make_url(db, doc) when is_map(doc) do
    doc
    |> Map.fetch!("id")
    |> make_url(db)
  end
end
