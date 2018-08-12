require Record

defmodule Barrel.Cursor do
  @moduledoc """
  The cursor allows for a series of
  document transformations, detailed below.

  ### Data transformations and usage

  1. Pass the query options

  The options map allows to pass a `limit`
  parameter to limit the maximum number of
  returned documents. The other param,
  `batch_size` allows to specify how many
  documents to fetch from the database at the
  same time. Bigger values of the batch size
  make usually for an lighter database load.

  2. Fetch by query

  Pass `"id": 1` or `"ids": [1, 2, 3]` to look
  for documents with a given ID. Otherwise, apply the
  other query params to all the documents in the database.
  The database client allows for conditional queries, with
  the syntax:

  ```
  $<operator>$<value>
  ```

  where `<operator>` can be any of "gt, "ge", "lt", "le", or "eq".
  "eq" is applied by defult if none is present. The `<value>` can
  be any erlang/elixir term as they all are possible to compare.

  3. Apply the projection

  Use the supplied projection to discard document key-value pairs
  that are specified with falsey (0 or false) values in the
  projection map. The keys with thruthy (1||true) values
  as well as the keys that don't appear in the projection
  map are shown in the result.

  ### Parameter examples

  query:

  ```
  %{
    "key1": "value1", # exact match
    "k2: "$ge$212231", # look for greater or equal values
    "id": "23VR94FJ8EJDF330", # look for a specific barrel document id
    "_rev": "4FQEFPEFJPO" # you can also search for a particular revision id
  }
  ```

  proj:

  ```
  %{
    "id": true,
    "k2": false
    # another keys are true or shown by default
  }
  ```

  opts:

  ```
  %{
    :limit => 10,
    :batch_size => 1 # the default
  }
  ```

  """

  @type barrel :: String.t()

  @type t :: %{
          barrel: barrel,
          query: %{optional(any()) => any()},
          proj: %{optional(atom()) => boolean() | integer()},
          opts: %{optional(atom()) => any()}
        }

  defstruct barrel: nil,
            query: %{},
            proj: %{},
            opts: %{}

  defimpl Enumerable do
    alias Barrel.{
      Database,
      Document
    }

    Record.defrecordp(:state, [:ids, :limit, :batch_size])

    def count(_enum) do
      {:error, __MODULE__}
    end

    def member?(_enum, _elem) do
      {:error, __MODULE__}
    end

    def reduce(%{barrel: barrel, query: query, proj: proj, opts: opts}, acc, reduce_fun) do
      start_fun = start_fun(barrel, query, opts)
      next_fun = next_fun(barrel, query, proj)
      after_fun = after_fun([])

      Stream.resource(start_fun, next_fun, after_fun).(acc, reduce_fun)
    end

    @doc """
    First, checks if the database exists.
    Then, it parses opts and passes them to state along with
    the supplied id's or all the id's in the database.
    """
    defp start_fun(barrel, query, opts) do
      fn ->
        if Database.exists?(barrel) == false do
          raise "inexisting database: #{barrel}"
        end

        # additional opts to be added here and passed to state eventually
        limit = Map.get(opts, :limit)
        batch_size = Map.get(opts, :batch_size, 1)

        case get_id_or_ids(query) do
          nil ->
            # get all document id's if no id's supplied
            case Document.ids(barrel) do
              {:ok, ids} ->
                state(ids: ids, limit: limit, batch_size: batch_size)

              {:error, :not_found} ->
                raise "the ids supplied are incorrect"

              {:error, reason} ->
                raise reason
            end

          id_or_ids when is_list(id_or_ids) ->
            state(ids: id_or_ids, limit: limit, batch_size: batch_size)
        end
      end
    end

    @spec get_id_or_ids(map()) :: list()
    defp get_id_or_ids(query) do
      # prioritize :id in query to use also to find one doc
      case query["id"] do
        nil ->
          case query["ids"] do
            nil ->
              nil

            ids ->
              ids
          end

        id ->
          [id]
      end
    end

    @doc """
    The limit is decreased after a succesfully returned document, while
    the ids are updated after succesfully fetching the document.
    """
    defp next_fun(barrel, query, proj) do
      fn
        state(limit: 0) = state ->
          {:halt, state}

        state(ids: []) = state ->
          {:halt, state}

        state(batch_size: 0) = state ->
          {:halt, state}

        state(ids: ids, limit: limit, batch_size: batch_size) = state ->
          with ids_batch <- ids |> Enum.take(batch_size),
               pending_ids <- ids |> Enum.drop(batch_size) do
            case Document.fetch(barrel, ids_batch) do
              {:ok, resps} ->
                with filtered <-
                       Enum.map(resps, fn
                         {:ok, doc} ->
                           doc_satisfies_query(doc, query)

                         {:error, _why} ->
                           %{}
                       end)
                       |> Enum.filter(fn doc -> doc != %{} end),
                     projected <- Enum.map(filtered, fn doc -> satisfies_proj(doc, proj) end) do
                  {
                    projected,
                    state(
                      state,
                      ids: pending_ids,
                      limit: update_limit(limit, batch_size),
                      batch_size: batch_size
                    )
                  }
                end

              {:error, :not_found} ->
                raise "document with the given ID not found"

              {:error, reason} ->
                raise reason
            end
          end
      end
    end

    @doc """
    Removes all the fields from `doc` which are represented by a
    falsey (0 or false) value in projection.
    """
    @spec satisfies_proj(map, map) :: map
    defp satisfies_proj(doc, proj) when doc == %{}, do: %{}
    defp satisfies_proj(doc, proj) when proj == %{}, do: doc

    @spec satisfies_proj(map, map) :: map
    defp satisfies_proj(doc, proj) do
      with falsey <- Enum.reject(proj, fn {k, v} -> is_truthy(k, v) end),
           not_projected <- falsey |> Enum.into(%{}) |> Map.keys() do
        doc
        |> Map.drop(not_projected)
      end
    end

    @doc """
    If there is no limit set, do not decrement it,
    effectively creating a potentially very large loop over
    all the id's in the database in the worst case.

    The default batch size is set to 1, same as in `start_fun/1`.
    """
    defp update_limit(limit, batch_size \\ 1) do
      case limit do
        nil -> nil
        l when is_integer(l) -> l - batch_size
      end
    end

    @doc """
    In the future, after remote connection is implemented in barrel,
    close it here.
    """
    defp after_fun(_) do
      fn _ ->
        :ok
      end
    end

    # @spec doc_satisfies_query(map, map | none) :: map
    # defp doc_satisfies_query(doc, query) when is_nil(query), do: doc
    # defp doc_satisfies_query(doc, query) when query == %{}, do: doc

    @spec doc_satisfies_query(map, map) :: map
    defp doc_satisfies_query(doc, query) do
      # remember that the id keys are useful only at fetch time, maybe do that in start_fun
      with id_keys <- ["id", "ids"],
           query <- Map.drop(query, id_keys) do
        if query
           |> Map.keys()
           |> Enum.any?(fn key ->
             not passes_value_filter?(Map.fetch!(doc, key), Map.fetch!(query, key))
           end) do
          %{}
        else
          doc
        end
      end
    end

    @doc """
    Look for presence of special characters in the passed
    query value that allow for other comparisions than equality.

    The avaliable comparisions for now are:

    + "$gt$" or > that allows only bigger values in the result set, as in
    the example query: %{:age => "$gt$18"} to show only documents where age = 18

    + "$ge$" or >=

    + "$lt$" or <

    + "$le$" or <=

    + "$eq$" or == which is also the **default** in case no special value filter is present

    All the previous comparisions are valid for all elrang temrs, integers and strings are among them.
    That means that you can even filter by alphabetical order in search.
    """
    @spec passes_value_filter?(any, any) :: boolean()
    defp passes_value_filter?(doc_val, query_val) do
      case get_compare_op(query_val) do
        {nil, query_val} ->
          Kernel.==(doc_val, query_val)

        {"gt", updt_query_val} ->
          Kernel.>(doc_val, updt_query_val)

        {"ge", updt_query_val} ->
          Kernel.>=(doc_val, updt_query_val)

        {"lt", updt_query_val} ->
          Kernel.<(doc_val, updt_query_val)

        {"le", updt_query_val} ->
          Kernel.<=(doc_val, updt_query_val)

        {"eq", updt_query_val} ->
          Kernel.==(doc_val, updt_query_val)

        {other_op, _query_val} ->
          raise "invalid query filter operation: #{other_op}"
      end
    end

    @doc """
    Check for presence and extract the comparision
    operator from the string query value.
    """
    defp get_compare_op(query_val) do
      case query_val |> to_string() |> String.starts_with?("$") do
        true ->
          with tokens <- query_val |> String.split("$"),
               ["", compare_op, new_query_val] <- tokens do
            {compare_op, new_query_val}
          end

        false ->
          {nil, query_val}
      end
    end

    @spec is_truthy(any, any) :: boolean()
    def is_truthy(k, v) do
      case v do
        1 ->
          true

        true ->
          true

        0 ->
          false

        false ->
          false

        other ->
          raise "invalid projection value, must be 0/1/true/false, is: #{other}"
      end
    end

    def slice(_enum) do
      {:error, __MODULE__}
    end
  end
end
