defmodule ReplicationTest do
  use ExUnit.Case
  alias BarrelEx.{
    Database,
    Document,
    Replication
  }

  setup do
    Database.delete!("sourcetest")
    Database.delete!("desttest")
  end

  @tag :skip
  test "is replication creation working" do
    Database.create!("sourcetest")
    Database.create!("desttest")
    doc1 = %{name: "John", surname: "McCarthy"}
    Document.create!("sourcetest", doc1)
    with Replication.create("sourcetest", "desttest") do
      db1 = Database.get!("sourcetest")
      db2 = Database.get!("desttest")
      assert db1.body.docs_count == db2.body.docs_count
    end
  end
end