# BarrelEx
## Elixir bindings for the BarrelDB API

Currently, only bindings to the REST API are supported.
Bindings directly to Erlang are pending to be done at the moment.

## Usage

To use the latest version, paste in mix.exs the following line in deps:

```elixir

{:barrel_ex,  git: "https://gitlab.com/barrel-db/Clients/barrel_ex", branch: "develop"}

```
And use in a module as you wish:

```elixir
defmodule MyModule do
  
  alias BarrelEx.{
    Database,
    Database.Document
  }
  
  def myfun do
    with {:ok, db} = Database.get(db) do
      Map.new([id: "1234", name: "Jakub", surname: "Janarek"])
      |> Document.create!(db)
  end
end

```