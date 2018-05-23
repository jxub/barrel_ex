defmodule DatabaseTest do
  use ExUnit.Case, async: true
  alias BarrelEx.Database

  setup do
    %{db: "ehlo", db2: "mongo", db3: "55**"}
  end

  test "database list status" do
    {:ok, _data} = Database.get()
  end

  test "list values correct" do
    data = Database.get!()
    assert data != nil
  end

  test "create and delete database status", %{db: db} do
    {:ok, _message1} = Database.delete(db)
    {:ok, _message2} = Database.create(db)
    {:ok, _message3} = Database.delete(db)
  end

  test "duplicated database deletion and creation", %{db2: db2} do
    {:ok, resp} = Database.delete(db2)
    assert %{ok: true} == resp.body
    {:ok, _data} = Database.create(db2)
    {:ok, data2} = Database.create(db2)
    assert %{message: "db exists"} == data2.body
    assert 409 == data2.status_code
  end

  test "create a database with an invalid name", %{db3: db3} do
    resp = Database.create!(db3)
    assert %{message: "db error"} = resp.body
  end
end
