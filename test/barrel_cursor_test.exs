defmodule BarrelCursorTest do
  use ExUnit.Case

  alias Barrel.{
    Cursor,
    Database,
    Document
  }

  setup do
    Application.ensure_all_started(:barrel)
    %{db: "testdb", db2: "testdb2"}
  end

  test "create a new empty cursor that implements enumerable", dbs do
    Database.delete(dbs.db)
    Database.create(dbs.db)

    with _c <- %Cursor{barrel: dbs.db, query: %{}, proj: %{}, opts: %{}} do
      assert :ok == Protocol.assert_impl!(Enumerable, Barrel.Cursor)
    end
  end

  test "create a cursor and get full documents with id query", dbs do
    Database.delete(dbs.db)
    Database.create(dbs.db)

    {:ok, doc_id, _rev_id} = Document.save_one(dbs.db, %{:a => 1, :b => 2})
    {:ok, doc_id1, _rev_id1} = Document.save_one(dbs.db, %{:c => 2, :d => 4})

    with query <- %{"ids" => [doc_id, doc_id1]},
         _doc_keys <- [:a, :b, "_rev", "id"],
         c <- %Cursor{barrel: dbs.db, query: query, proj: %{}, opts: %{}},
         results <- c |> Enum.to_list() do
      assert length(results) == 2

      with ids_fetched <- Enum.map(results, fn res -> Map.fetch!(res, "id") end) do
        assert Enum.member?(ids_fetched, doc_id) == true
        assert Enum.member?(ids_fetched, doc_id1) == true
      end
    end
  end

  test "check if projection removes unneeded fields from results", dbs do
    Database.delete(dbs.db)
    Database.create(dbs.db)

    {:ok, _doc_id, _rev_id} = Document.save_one(dbs.db, %{:a => 1, :b => 2})
    {:ok, _doc_id1, _rev_id1} = Document.save_one(dbs.db, %{:a => 2, :b => 4})

    with c <- %Barrel.Cursor{
           barrel: dbs.db,
           query: %{},
           proj: %{:a => 0, "id" => false, :b => 1},
           opts: %{:limit => 2}
         },
         results <- c |> Enum.to_list() do
      assert length(results) == 2

      for r <- results do
        assert Map.keys(r) |> Enum.member?(:a) == false
        assert Map.keys(r) |> Enum.member?("id") == false
        assert Map.keys(r) |> Enum.member?(:b) == true
      end
    end
  end

  test "check if limit works properly", dbs do
    Database.delete(dbs.db)
    Database.create(dbs.db)

    {:ok, _doc_id, _rev_id} = Document.save_one(dbs.db, %{:a => 1, :b => 2})
    {:ok, _doc_id1, _rev_id1} = Document.save_one(dbs.db, %{:a => 2, :b => 4})
    {:ok, _doc_id2, _rev_id2} = Document.save_one(dbs.db, %{:a => 4, :b => 6})

    with c <- %Barrel.Cursor{barrel: dbs.db, query: %{}, proj: %{}, opts: %{:limit => 2}},
         results <- c |> Enum.to_list() do
      assert length(results) == 2
    end
  end

  test "check if batch size returns n documents", dbs do
    Database.delete(dbs.db)
    Database.create(dbs.db)

    {:ok, _doc_id0, _rev_id0} = Document.save_one(dbs.db, %{:a => 1, :b => 2})
    {:ok, _doc_id1, _rev_id1} = Document.save_one(dbs.db, %{:a => 1, :b => 4})
    {:ok, _doc_id2, _rev_id2} = Document.save_one(dbs.db, %{:a => 1, :b => 6})
    {:ok, _doc_id3, _rev_id3} = Document.save_one(dbs.db, %{:a => 1, :b => 2})
    {:ok, _doc_id4, _rev_id4} = Document.save_one(dbs.db, %{:a => 1, :b => 4})
    {:ok, _doc_id5, _rev_id5} = Document.save_one(dbs.db, %{:a => 1, :b => 6})

    with c <- %Barrel.Cursor{
           barrel: dbs.db,
           query: %{:a => 1},
           proj: %{:a => 0, :b => true},
           opts: %{:batch_size => 2}
         },
         results <- c |> Enum.to_list() do
      assert length(results) == 6
    end
  end

  test "check if conditional querying returns the desired documents", dbs do
    Database.delete(dbs.db)
    Database.create(dbs.db)

    {:ok, _doc_id0, _rev_id0} = Document.save_one(dbs.db, %{:age => "20", :name => "Diego"})
    {:ok, _doc_id1, _rev_id1} = Document.save_one(dbs.db, %{:age => "20", :name => "Jorge"})
    {:ok, _doc_id2, _rev_id2} = Document.save_one(dbs.db, %{:age => "18", :name => "Juan"})
    {:ok, _doc_id3, _rev_id3} = Document.save_one(dbs.db, %{:age => "21", :name => "Santi"})
    {:ok, _doc_id4, _rev_id4} = Document.save_one(dbs.db, %{:age => "20", :name => "Jakub"})
    {:ok, _doc_id5, _rev_id5} = Document.save_one(dbs.db, %{:age => "1", :name => "Toni"})

    with c <- %Barrel.Cursor{
           barrel: dbs.db,
           query: %{:age => "$gt$18"},
           proj: %{"_rev" => false, "id" => false, :age => true, :name => true},
           opts: %{}
         } do
      results = c |> Enum.to_list()

      assert length(results) == 4

      for result <- results do
        for key <- Map.keys(result) do
          assert key not in ["_rev", "id"]
          assert key in [:name, :age]
        end
      end
    end
  end
end
