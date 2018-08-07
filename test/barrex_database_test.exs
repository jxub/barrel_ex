defmodule BarrexDatabaseTest do
  use ExUnit.Case

  alias Barrex.{
    Database
  }

  setup do
    Application.ensure_all_started(:barrel)
    %{db: "testdb", db2: "testdb2"}
  end

  test "create a new database", dbs do
    Database.delete(dbs.db)

    case Database.create(dbs.db) do
      {:ok, :created} ->
        :ok

      other ->
        raise other
    end
  end

  test "create an existing database", dbs do
    Database.delete(dbs.db)

    # TODO: discuss if this return tuple makes sense
    {:ok, :created} = Database.create(dbs.db)

    case Database.create(dbs.db) do
      {:error, :already_exists} ->
        :ok

      other ->
        raise other
    end
  end

  test "delete a not existing database", dbs do
    Database.delete(dbs.db)

    case Database.delete(dbs.db) do
      {:error, :not_found} ->
        :ok

      other ->
        raise other
    end
  end

  test "delete an existing database", dbs do
    Database.create(dbs.db)

    case Database.delete(dbs.db) do
      {:ok, :deleted} ->
        :ok

      other ->
        raise other
    end
  end

  test "get information about an existing database", dbs do
    Database.create(dbs.db)

    case Database.info(dbs.db) do
      {:error, :not_found} ->
        :ok

      {:ok, info} when is_map(info) ->
        :ok

      other ->
        raise other
    end
  end

  test "get information about a not found database", dbs do
    Database.delete(dbs.db)

    case Database.info(dbs.db) do
      {:error, :not_found} ->
        :ok

      other ->
        raise other
    end
  end
end
