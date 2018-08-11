# Barrel

## Elixir bindings for BarrelDB

This package contains the Elixir bindings directly to Erlang code.
Bindings to the (perhaps more stable) HTTP BarrelDB API can be found [here](https://gitlab.com/barrel-db/Clients/barrel_ex_http). Please note that
the API of barrel_ex might experience breaking changes given the rapid pace
of development of the underlying barrel package.

## Install! :wave:

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `barrel_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:barrel_ex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/barrel_ex](https://hexdocs.pm/barrel_ex).

## Use! :muscle:


To use the latest version, paste the following line in mix.exs deps:

```elixir
{:barrel_ex,  git: "https://gitlab.com/barrel-db/Clients/barrel_ex", branch: "develop"}
```

And use as you wish, here's a brief guide (please note that things may change in
the future, so I'll try to update the examples below).

Remember that in order to use barrel_ex it's more convenient to alias all the
used modules, from the namespace `Barrel`.
`Barrel.Database` and `Barrel.Document` are the most commonly used modules from there,
but sometimes you might use some lower-level functionality from `Barrel.Index` or other.

Create a barrel (database) @ local node (remote connection support coming soon):

```elixir
alias Barrel.{
  Database,
  Document
}

  def create_user(name, surname) do
    with {:ok, db} = Database.get(db) do
      Map.new([id: "1234", name: name, surname: surname])
      |> Document.create!(db)
    end
  end
end
```

For more usage examples, have a look at the tests, in the `tests/` directory.

## Contribute! :rocket:

Get the code for Barrel:

```bash
$ git clone https://gitlab.com/barrel-db/Clients/barrel_ex
$ cd barrel_ex
```

And test the application with:

```bash
$ mix test
```

You can also check the test coverage and run the quality check with credo:

```bash
$ mix coveralls
$ mix credo
```
