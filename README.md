# barrel_ex
## Elixir bindings for the BarrelDB API


## Usage

```elixir

alias BarrelEx.{
  Database,
  Database.Document
}
with {:ok, db} = Database.get(db) do
  %{"id": "1234", "name": "Jakub", "surname": "Janarek"}
    |> Document.create!(db)
end

```