defmodule BarrexDocumentTest do
  use ExUnit.Case

  alias Barrex.{
    Database,
    Document
  }

  setup do
    Application.ensure_all_started(:barrel)
    # TODO: delete :barrel_store_sup.start_store(:default, :barrel_memory_storage, %{})
    %{dbname: "testdb"}
  end

  test "multiple docs", %{dbname: dbname} do
    Database.delete(dbname)
    Database.create(dbname)

    with docs <- Stream.repeatedly(&make_person_doc/0) |> Enum.take(40),
         resps <- Document.save(dbname, docs),
         ids <-
           resps
           |> Enum.map(fn res -> res |> Tuple.to_list() |> Enum.at(1) end) do
      assert length(ids) == 40

      with {:ok, all} <- Document.ids(dbname) do
        assert length(all) == 40
      end
    end

    Database.delete(dbname)
  end

  defp make_person_doc do
    with age <- :rand.uniform(500),
         index <- :rand.uniform(3) - 1,
         name <- Enum.at(["juan", "antonio", "marcos"], index) do
      %{:name => name, :age => age}
    end
  end
end
