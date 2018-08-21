defmodule BarrelStreamsTest do
  use ExUnit.Case

  alias Barrel.{
    Database,
    Document,
    Stream
  }

  setup do
    Application.ensure_all_started(:barrel)
    # TODO: delete :barrel_store_sup.start_store(:default, :barrel_memory_storage, %{})
    %{dbname: "testdb"}
  end

  @tag :deprecated
  test "basic stream implementation", %{dbname: dbname} do
    Database.delete(dbname)
    assert {:ok, :created} == Database.create(dbname)

    :timer.sleep(100)
    stream = Stream.new(dbname)

    {:ok, stream} = Stream.subscribe(stream)
    docs = [%{"id" => "a", "k" => "v"}, %{"id" => "b", "k" => "v2"}]
    [{:ok, "a", rev1}, {:ok, "b", rev2}] = Document.save(dbname, docs)
    :timer.sleep(200)

    receive do
      {:changes, _stream, changes, last_seq} ->
        # IO.inspect({:changes, stream, changes, last_seq})
        # Pattern matching with assert fails on complex maps,
        # so just do a raw `=`.
        seq1 = Enum.at(changes, 0) |> Map.fetch!("seq")
        seq2 = Enum.at(changes, 1) |> Map.fetch!("seq")

        assert changes == [
                 %{
                   "id" => "a",
                   "rev" => rev1,
                   "seq" => seq1,
                   "changes" => [rev1],
                   "doc" => Enum.at(docs, 0)
                 },
                 %{
                   "id" => "b",
                   "rev" => rev2,
                   "seq" => seq2,
                   "changes" => [rev2],
                   "doc" => Enum.at(docs, 1)
                 }
               ]

        assert last_seq == seq2
    after
      5_000 -> raise "receive timeout"
    end

    assert :ok == Stream.unsubscribe(stream)
    :timer.sleep(200)
    assert {:ok, :deleted} == Database.delete(dbname)
  end
end
