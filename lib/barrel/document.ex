defmodule BarrelEx.Document do
  alias BarrelEx.Request

  ## GET

  @spec get(String.t()) :: {atom(), map}
  def get(db) do
    db
    |> make_url()
    |> Request.get()
  end

  @spec get(String.t()) :: map
  def get!(db) do
    db
    |> make_url()
    |> Request.get!()
  end

  @spec get(String.t(), list()) :: {atom(), map}
  def get(db, options) when is_list(options) do
    with url = make_url(db) do
      Request.get(url, [], params: options)
    end
  end

  @spec get(String.t(), map) :: {atom(), map}
  def get(db, options) when is_map(options) do
    Map.to_list(options)
    |> atomize_keys()
    |> get(db)
  end

  @spec get(String.t(), list()) :: map
  def get!(db, options) when is_list(options) do
    with url = make_url(db) do
      Request.get!(url, [], params: options)
    end
  end

  @spec get(String.t(), map) :: map
  def get!(db, options) when is_map(options) do
    Map.to_list(options)
    |> atomize_keys()
    |> get!(db)
  end

  ## CREATE

  @spec create(String.t(), map | none()) :: {atom(), map}
  def create(db, doc \\ %{}) do
    with url = make_url(db) do
      Request.post(url, doc)
    end
  end

  @spec create!(String.t(), map | none()) :: map
  def create!(db, doc \\ %{}) do
    with url = make_url(db) do
      Request.post!(url, doc)
    end
  end

  ## DELETE

  @spec delete(String.t(), map) :: {atom(), map}
  def delete(db, doc) when is_map(doc) do
    Map.fetch!(doc, "id")
    |> delete(db)
  end

  @spec delete(String.t(), String.t()) :: {atom(), map}
  def delete(db, doc_id) do
    with url = make_url(db, doc_id) do
      Request.delete(url)
    end
  end

  @spec delete!(String.t(), map) :: {atom(), map}
  def delete!(db, doc) when is_map(doc) do
    Map.fetch!(doc, "id")
    |> delete!(db)
  end

  @spec delete!(String.t(), String.t()) :: {atom(), map}
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
