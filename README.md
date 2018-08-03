# Barrex

## Elixir bindings for BarrelDB

This package contains the Elixir bindings directly to Erlang code.
Bindings to the (perhaps more stable) HTTP BarrelDB API can be found [here](https://gitlab.com/barrel-db/Clients/barrel_ex_http).

## Usage

To use the latest version, paste the following line in mix.exs deps:

```elixir
{:barrel_ex,  git: "https://gitlab.com/barrel-db/Clients/barrel_ex", branch: "develop"}
```

And use as you wish:

```elixir
defmodule Users do
  
  alias BarrelEx.{
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

For more usage examples, have a look at the tests.

## Development

Get the code for BarrelEx:

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


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `barrex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:barrex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/barrex](https://hexdocs.pm/barrex).

