defmodule BarrelEx.Database do
  alias BarrelEx.Request

  ## GET

  @spec get(none()) :: {atom(), map}
  def get do
    make_url()
    |> Request.get()
  end

  @spec get(none()) :: map
  def get! do
    make_url()
    |> Request.get!()
  end

  @spec get(String.t) :: {atom(), map}
  def get(db) do
    make_url(db)
    |> Request.get()
  end

  @spec get(String.t) :: map
  def get!(db) do
    make_url(db)
    |> Request.get!()
  end

  ## CREATE

  @spec create(String.t)  :: {atom(), map}
  def create(db) do
    with url = make_url(),
         db = Map.new(["database_id": db]) do
      Request.post(url, db)
    end
  end

  @spec create!(String.t)  :: map
  def create!(db) do
    with url = make_url(),
         db = Map.new(["database_id": db]) do
      Request.post!(url, db)
    end
  end

  ## DELETE

  @spec delete(String.t)  :: {atom(), map}
  def delete(db) do
    make_url(db)
    |> Request.delete() 
  end

  @spec delete!(String.t)  :: map
  def delete!(db) do
    make_url(db)
    |> Request.delete!()
  end

  ## UTILS

  defp make_url do
    "dbs/"
  end

  defp make_url(db) do
    make_url() <> db
  end
end
