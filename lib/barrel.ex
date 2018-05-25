defmodule BarrelEx do
  @moduledoc """
  Main module for the code.

  Usage:

  defmodule MyModule do
    use BarrelEx
    
    def myfun do
      with {:ok, db} = Database.get(db) do
        Map.new([id: "1234", name: "Jakub", surname: "Janarek"])
        |> Document.create!(db)
      end
    end
  end
  """
  defmacro __using__(_) do
    quote do
      alias BarrelEx.{
        Database,
        Document,
        Exception,
        Replication,
        Server,
        Sysdoc
      }
    end
  end
end
