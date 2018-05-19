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

  # @tag :skip
  test "creates many documents", %{db: db} do
    for n <- 1..20 do
      doc = Map.new(id: :rand.uniform(1_000_000), number: n, dummy: "a string")
      Document.create!(db, doc)
    end
  end

  # @tag :skip
  test "deletes all documents", %{db: db} do
    {:ok, _docs} = Database.get(db)
  end
end
