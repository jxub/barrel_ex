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

  # TODO: @spec get(String.t(), String.t(), boolean())

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

  @spec delete(String.t(), String.t(), String.t() | none()) :: {atom(), map()}
  def delete(db, doc_id, e_tag \\ "") do
    with url = make_url(db, doc_id),
         headers = make_e_tag(e_tag) do
      Request.delete(url, headers)
    end
  end

  @spec delete!(String.t(), String.t(), String.t() | none()) :: map()
  def delete!(db, doc_id, e_tag \\ "") do
    with url = make_url(db, doc_id),
         headers = make_e_tag(e_tag) do
      Request.delete!(url, headers)
    end
  end

  ## UPDATE

  @spec update(String.t(), String.t(), map(), String.t(), boolean()) :: {atom(), map()}
  def update(db, doc_id, doc, e_tag \\ "", edit \\ false) do
    with url = make_url(db, doc_id) do
      doc = Map.put_new(doc, "id", doc_id) # to add doc_id to body if doesn't exist
      Request.put(url, doc, make_e_tag(e_tag), [edit: edit])
    end
  end

  @spec update(String.t(), String.t(), map(), String.t(), boolean()) :: map()
  def update!(db, doc_id, doc, e_tag \\ "", edit \\ false) do
    with url = make_url(db, doc_id) do
      doc = Map.put_new(doc, "id", doc_id) # to add doc_id to body if doesn't exist
      Request.put!(url, doc, make_e_tag(e_tag), [edit: edit])
    end
  end

  ## HISTORY

  ## UTILS

  defp make_e_tag(e_tag) do
    case is_bitstring(e_tag) do
      true -> ["ETag: " <> e_tag]
      _ -> []
    end
  end

  defp make_id_match(doc_ids) do
    case is_list(doc_ids) do
      true -> ["x-barrel-id-match: " <> Enum.join(doc_ids, ", ")] # TODO: test this header
      _ -> []
    end
  end

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
