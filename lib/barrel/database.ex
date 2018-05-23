defmodule BarrelEx.Database do
  @moduledoc """
  API for interacting with a BarrelDB database.
  """
  alias BarrelEx.Request

  ## GET

  @doc """
  Get list of available databases
  and the response status.
  """
  @spec get(none()) :: {atom(), map()}
  def get do
    with url = make_url() do
      Request.get(url)
    end
  end

  @doc """
  Get list of available databases.
  """
  @spec get(none()) :: map()
  def get! do
    with url = make_url() do
      Request.get!(url)
    end
  end

  @doc """
  Get information about the database `db`
  and the response status.
  """
  @spec get(String.t()) :: {atom(), map()}
  def get(db) do
    with url = make_url(db) do
      Request.get(url)
    end
  end

  @doc """
  Get information about the database `db`.
  """
  @spec get(String.t()) :: map()
  def get!(db) do
    with url = make_url(db) do
      Request.get!(url)
    end
  end

  ## CREATE

  @doc """
  Create a new database with the database_id
  `db_id`. Returns the database info and response status.
  """
  @spec create(String.t()) :: {atom(), map()}
  def create(db_id) when is_bitstring(db_id) do
    db = Map.new(database_id: db_id)
    create(db)
  end

  @doc """
  Create a new database with the database configuration
  `db`. Returns database info and response status.
  """
  @spec create(map()) :: {atom(), map()}
  def create(db) when is_map(db) do
    with url = make_url() do
      Request.post(url, db)
    end
  end

  @doc """
  Create a new database with the database_id
  `db_id`. Returns database info.
  """
  @spec create!(String.t()) :: map()
  def create!(db_id) when is_bitstring(db_id) do
    db = Map.new(database_id: db_id)
    create!(db)
  end

  @doc """
  Create a new database with the database configuration
  `db`. Returns database info and response status.
  """
  @spec create!(map()) :: map()
  def create!(db) when is_map(db) do
    with url = make_url() do
      Request.post!(url, db)
    end
  end

  ## DELETE

  @doc """
  Delete a database named `db`, returns status and database info.
  """
  @spec delete(String.t()) :: {atom(), map()}
  def delete(db) do
    with url = make_url(db) do
      Request.delete(url)
    end
  end

  @doc """
  Delete a database named `db`, returns the database info.
  """
  @spec delete!(String.t()) :: map()
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
