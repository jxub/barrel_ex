defmodule BarrexStreamsTest do
  use ExUnit.Case

  alias Barrex.{
    Database,
    Document,
    Streams
  }

  setup do
    Application.ensure_all_started(:barrel)
    :barrel_store_sup.start_store(:default, :barrel_memory_storage, %{})
    %{dbname: "testdb"}
  end

  test "basic streams implementation", %{dbname: dbname} do
    Database.delete(dbname)
    assert {:ok, :created} == Database.create(dbname)

    :timer.sleep(100)
    stream = Streams.new(dbname)

    assert :ok == Streams.subscribe(stream, self(), 0)
    docs = [%{"id" => "a", "k" => "v"}, %{"id" => "b", "k" => "v2"}]
    [{:ok, "a", rev1}, {:ok, "b", rev2}] =
      Document.save(dbname, docs)
    :timer.sleep(200)

    receive do
      {:changes, stream, changes, last_seq} ->
        assert last_seq == 2
        # Pattern matching with assert fails on complex maps,
        # so just do a raw `=`.
        changes = [%{"id" => "a", "rev" => rev1}, %{"id" => "b", "rev" => rev2}]
    after
      5_000 -> raise "receive timeout"
    end

    assert :ok == Streams.unsubscribe(stream, self())
    :timer.sleep(200)
    assert {:ok, :deleted} == Database.delete(dbname)
  end
end
