defmodule DocumentTest do
  alias BarrelEx.{
    Database,
    Document
  }

  setup do
    db = "test_db"
    Database.create!(db)

    on_exit(fn ->
      Database.delete!(db)
    end)

    %{db: db}
  end

  test "creates many documents", %{db: db} do
    for n <- 1..20 do
      doc = %{id: :rand.uniform(10000), number: n, dummy: "a string"}
      Document.create!(db, doc)
    end
  end

  test "deletes all documents", %{db: db} do
    docs = Database.get(db)
  end
end
