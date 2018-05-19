defmodule BarrelEx.Database do
  @moduledoc """
  API for interacting with a BarrelDB database.
  """
  alias BarrelEx.Request

  ## GET

  @spec get(none()) :: {atom(), map}
  def get do
    with url = make_url() do
      Request.get(url)
    end
  end

  @spec get(none()) :: map
  def get! do
    with url = make_url() do
      Request.get!(url)
    end
  end

  @spec get(String.t()) :: {atom(), map}
  def get(db) do
    with url = make_url(db) do
      Request.get(url)
    end
  end

  @spec get(String.t()) :: map
  def get!(db) do
    with url = make_url(db) do
      Request.get!(url)
    end
  end

  ## CREATE

  @spec create(String.t()) :: {atom(), map}
  def create(db) do
    with url = make_url(),
         db = Map.new(database_id: db) do
      Request.post(url, db)
    end
  end

  @spec create!(String.t()) :: map
  def create!(db) do
    with url = make_url(),
         db = Map.new(database_id: db) do
      Request.post!(url, db)
    end
  end

  ## DELETE

  @spec delete(String.t()) :: {atom(), map}
  def delete(db) do
    with url = make_url(db) do
      Request.delete(url)
    end
  end

  @spec delete!(String.t()) :: map
  def delete!(db) do
    with url = make_url(db) do
      Request.delete!(url)
    end
  end

  ## UTILS

  defp make_url do
    "dbs/"
  end

  defp make_url(db) do
    make_url() <> db
  end
end
