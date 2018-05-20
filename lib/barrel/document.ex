defmodule BarrelEx.Document do
  @moduledoc """
  API for interacting with a BarrelDB document.
  """
  alias BarrelEx.Request

  ## TODO: some header args like x-barrel-id-match and ETag
  ## are in headers, accept them too

  ## GET - ALL DOCUMENTS SIMPLE

  @spec get(String.t()) :: {atom(), map()}
  def get(db) do
    db
    |> make_url()
    |> Request.get()
  end

  @spec get!(String.t()) :: map()
  def get!(db) do
    db
    |> make_url()
    |> Request.get!()
  end

  ## GET - ALL DOCUMENTS OPTIONS

  @spec get(String.t(), list()) :: {atom(), map()}
  def get(db, options) when is_list(options) do
    with url = make_url(db) do
      Request.get(url, [], params: options)
    end
  end

  @spec get(String.t(), map()) :: {atom(), map()}
  def get(db, options) when is_map(options) do
    with options = Map.to_list(options) do
      options
      |> atomize_keys()
      |> get(db)
    end
  end

  @spec get!(String.t(), list()) :: map()
  def get!(db, options) when is_list(options) do
    with url = make_url(db) do
      Request.get!(url, [], params: options)
    end
  end

  @spec get!(String.t(), map()) :: map()
  def get!(db, options) when is_map(options) do
    with options = Map.to_list(options) do
      options
      |> atomize_keys()
      |> get!(db)
    end
  end

  ## GET - ONE DOCUMENT SIMPLE

  @spec get(String.t(), String.t()) :: {atom(), map()}
  def get(db, doc_id) do
    with url = make_url(db, doc_id) do
      Request.get(url)
    end
  end

  @spec get!(String.t(), String.t()) :: {atom(), map()}
  def get!(db, doc_id) do
    with url = make_url(db, doc_id) do
      Request.get!(url)
    end
  end

  ## GET - ONE DOCUMENT OPTIONS

  # TODO: @spec get(String.t(), String.t(), bool)

  ## CREATE

  @spec create(String.t(), map() | none()) :: {atom(), map()}
  def create(db, doc \\ %{}) do
    with url = make_url(db) do
      Request.post(url, doc)
    end
  end

  @spec create!(String.t(), map() | none()) :: map()
  def create!(db, doc \\ %{}) do
    with url = make_url(db) do
      Request.post!(url, doc)
    end
  end

  ## DELETE

  @spec delete(String.t(), map()) :: {atom(), map()}
  def delete(db, doc) when is_map(doc) do
    with doc = Map.fetch!(doc, "id") do
      delete(db, doc)
    end
  end

  @spec delete(String.t(), String.t()) :: {atom(), map()}
  def delete(db, doc_id) do
    with url = make_url(db, doc_id) do
      Request.delete(url)
    end
  end

  @spec delete!(String.t(), map()) :: {atom(), map()}
  def delete!(db, doc) when is_map(doc) do
    with doc = Map.fetch!(doc, "id") do
      delete!(db, doc)
    end
  end

  @spec delete!(String.t(), String.t()) :: {atom(), map()}
  def delete!(db, doc_id) do
    with url = make_url(db, doc_id) do
      Request.delete!(url)
    end
  end

  ## UTILS

  defp make_url(db) do
    "dbs/" <> db <> "/docs/"
  end

  defp make_url(db, doc_id) do
    make_url(db) <> doc_id
  end

  defp atomize_keys(list) do
    Enum.map(list, fn {k, v} -> {String.to_atom(k), v} end)
  end
end
