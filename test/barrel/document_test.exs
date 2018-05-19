defmodule DocumentTest do
  use ExUnit.Case

  alias BarrelEx.{
    Database,
    Document
  }

  setup do
    db = "test_db"
    Database.delete!(db)
    Database.create!(db)

    on_exit(fn ->
      Database.delete!(db)
    end)

    %{db: db}
  end

  test "creates one document without id", %{db: db} do
    doc = Map.new(number: 1, dummy: "a string")
    Document.create!(db, doc)
  end

  test "creates many documents without id", %{db: db} do
    for n <- 1..20 do
      doc = Map.new(number: n, dummy: "a string")
      Document.create!(db, doc)
    end
  end

  test "deletes all documents", %{db: db} do
    {:ok, _docs} = Database.get(db)
  end
end
