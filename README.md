# :barrel_ex

## Barrel-db Elixir native client

This package contains the Elixir bindings directly to the Erlang code of
[Barrel-db](https://barrel-db.org/),
with some extra functionality on top of it, mostly an Elixir-centric API,
support for iteration of the results and fine-grained query and projection
capabilities similar to the ones found in Mongo and other NoSQL databases.

Bindings to the (perhaps more stable) HTTP Barrel-db API can be found [here](https://gitlab.com/barrel-db/Clients/barrel_ex_http). Please note that
the API of barrel_ex might experience breaking changes given the rapid pace
of development of the underlying barrel package.

## Install! :wave:

To use the latest version, paste the following line in mix.exs deps:

```elixir
{:barrel_ex,  git: "https://gitlab.com/barrel-db/Clients/barrel_ex", branch: "develop"}
```

And use at wish.

When it'll be [available in Hex](https://hex.pm/docs/publish) which is shortly, the package will be possible to instal
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


I hate packages with next to no documentation, so in this section there's a brief 
explanation of Barrel-db and a guide 
for prospective users. Please note that things may change in
the future, so I'll try to update the examples below.

Barrel-db orients around the concepts of:

+ *documents* which at BEAM level are actually maps with a unique ID key and
other pairs of keys-values that represent the given data.
+ *barrels* which are something akin to collections
in other NoSQL stores and loosely related to tables in SQL databases, and contain documents. There isn't an enforced structure of documents but it's better to have the same keys in a barrel.
+ *stores* which are storages or databases in an erlang node which host one or many
barrels. In the current impementation of Barrel-db there's only one store but configuration of many stores with possibly different storage backends was possible in the past versions and might be enabled in the future again.

In order to use barrel_ex it's more convenient to alias all the
used modules, from the namespace `Barrel`.
`Barrel.Database` which manipulates barrels and `Barrel.Document` which provides facilities for working with documents in a given barrel are the most commonly used modules from there,
but sometimes you might use some lower-level functionality from `Barrel.Index` or other.

- Create a barrel (database) at the local node (remote connection support coming soon):

```elixir
alias Barrel.Database

Database.create("unoriginal_name")
```

- Insert a document to this database:

```elixir
alias Barrel.{
  Database,
  Document
}

with db <- "unoriginal_name",
     true <- Database.exists?(db),
     boring_doc <- Map.new([id: "1234", name: name, surname: surname]) do
  Document.save_one(db, boring_doc)
end
```

- Get one documents by document ID from a database and remove it afterwards:

```elixir
alias Barrel.Document

with db <- "unoriginal_name",
     doc_id <- "1234",
     {:ok, doc} <- Document.fetch_one(db, doc_id) do
  Document.delete(db, [doc]) # second arg to delete must be a list
  # use Document.purge_one(db, doc_id) to only remove the document from the local filesystem
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
