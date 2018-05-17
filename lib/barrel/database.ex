defmodule BarrelEx.Database do
  alias BarrelEx.Request

  # TODO: utils to do url join independently of `/`

  @database_url "dbs/"
  @database_id "database_id"

  def get do
    Request.get(@database_url)
  end

  def get! do
    Request.get!(@database_url)
  end

  def get(db) do
    Request.get(@database_url <> db)
  end

  def get!(db) do
    Request.get!(@database_url <> db)
  end

  def create(db) do
    body = %{@database_id => db}

    Request.post(@database_url, body)
  end

  def create!(db) do
    body = %{@database_id => db}

    Request.post!(@database_url, body)
  end

  def delete(db) do
    Request.delete(@database_url <> db)
  end

  def delete!(db) do
    Request.delete!(@database_url <> db)
  end
end
