# BarrelEx
## Elixir bindings for the BarrelDB API

Currently, only bindings to the REST API are supported.
Bindings directly to Erlang are pending to be done at the moment.

## Usage

To use the latest version, paste the following line in mix.exs deps:

```elixir
{:barrel_ex,  git: "https://gitlab.com/barrel-db/Clients/barrel_ex", branch: "develop"}
```

And use as you wish:

```elixir
defmodule MyModule do
  
  alias BarrelEx.{
    Database,
    Document
  }
  
  def myfun do
    with {:ok, db} = Database.get(db) do
      Map.new([id: "1234", name: "Jakub", surname: "Janarek"])
      |> Document.create!(db)
    end
  end
end
```

## Development

Get the code for barrel-platform first, compile it and run in
the background as follows:

```bash
$ git clone https://gitlab.com/barrel-db/barrel-platform
$ cd barrel-platform
$ make rel
$ ./_build/prod/rel/barrel/bin/barrel start
```

Then, get the code for BarrelEx:

```bash
$ git clone https://gitlab.com/barrel-db/Clients/barrel_ex
$ cd barrel_ex
```

Finally, test the application with:

```bash
$ mix test
```

You can also check the test coverage and run the quality check with credo:

```bash
$ mix coveralls
$ mix credo
```
