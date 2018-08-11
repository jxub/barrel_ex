defmodule BarrelDocumentTest do
  use ExUnit.Case

  alias Barrel.{
    Database,
    Document
  }

  setup do
    Application.ensure_all_started(:barrel)
    # TODO: delete :barrel_store_sup.start_store(:default, :barrel_memory_storage, %{})
    %{dbname: "testdb"}
  end

  test "save and get ids for multiple docs", %{dbname: dbname} do
    Database.delete(dbname)
    Database.create(dbname)

    with docs <- Stream.repeatedly(&make_sample_doc/0) |> Enum.take(40),
         resps <- Document.save(dbname, docs),
         ids <-
           resps
           |> Tuple.to_list()
           |> Enum.at(1)
           |> Enum.map(fn res -> res |> Tuple.to_list() |> Enum.at(1) end) do
      assert length(ids) == 40

      with {:ok, all} <- Document.ids(dbname) do
        assert length(all) == 40
      end
    end

    Database.delete(dbname)
  end

  test "save many and fetch all docs", %{dbname: dbname} do
    doc_num = 10
    Database.delete(dbname)
    Database.create(dbname)

    with docs <- Stream.repeatedly(&make_sample_doc/0) |> Enum.take(doc_num) do
      with {:ok, reps} <- Document.save(dbname, docs) do
        for resp <- resps do
          case resp do
            {:ok, doc_id, rev_id} ->
              :ok

            {:error, :db_not_found} ->
              raise "database error: database not found"

            {:error, {:conflict, reason}} ->
              raise "document error: #{reason}"
          end
        end
      end
    end

    case Document.fetch_all(dbname) do
      {:ok, docs} ->
        case length(docs) do
          doc_num ->
            :ok

          _ ->
            raise "Document.fetch_all/1 works incorrectly"
        end

      _ ->
        raise "Document.fetch_all/1 works incorrectly"
    end
  end

  test "save and fetch one doc and get its id", %{dbname: dbname} do
    Database.delete(dbname)
    Database.create(dbname)

    with doc <- %{:id => 12345, :key => :value},
         {:ok, doc_id, rev_id} <- Document.save_one(barrel, doc),
         doc_ids <- [doc_id],
         {:ok, results} <- Document.fetch(dbname, doc_ids) do
      for res <- results do
        case res do
          {:ok, :not_found} ->
            raise "document not found, Document.fetch/1 works incorrectly"

          {:ok, doc} when is_map(doc) ->
            :ok

          {:error, reason} ->
            raise "other error: #{reason}"
        end
      end
    end

    with ids <- Document.ids(dbname) do
      case length(ids) do
        1 ->
          :ok

        2 ->
          raise "more ids in database than expected (maybe some internal docs)"
      end
    end
  end

  defp make_sample_doc do
    with age <- :rand.uniform(500),
         index <- :rand.uniform(3) - 1,
         name <- Enum.at(["juan", "antonio", "marcos"], index) do
      %{:name => name, :age => age}
    end
  end
end
