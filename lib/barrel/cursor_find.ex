require Record

defmodule Barrel.CursorFind do
  @moduledoc """
  query:

  %{
    "key1": "value1",
    "k2: 212231
    # id
  }

  proj:

  %{
    "id": true,
    "k2": false,
  }

  opts:

  %{
    limit: 10
  }
  
  """

  @type barrel :: String.t()
  

  @type t :: %{
    barrel: barrel,
    query: %{optional(any()) => any()},
    proj: %{optional(any()) => boolean() | integer()},
    opts: %{optional(atom()) => any()}
  }

  defstruct [
    :barrel,
    :query,
    :proj,
    :opts
  ]

  defimpl Enumerable do
    alias Barrel.{
      Database,
      Document
    }

    Record.defrecordp(:state, [:ids, :limit])

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

        limit = opts[:limit]
        # additional opts to be added here and passed to state eventually
        # batch_size = opts[:batch_size]

        # prioritize :id in query to use also to find one doc
        ids = if query[:id], do: [query.id], else: query[:ids]

        case Map.fetch(query, :ids) do
          {:ok, ids} ->
              state(ids: ids, limit: limit)

          :error ->
            case Document.ids(barrel) do
              {:ok, ids} ->
                state(ids: ids, limit: limit)

              {:error, reason} ->
                raise reason
            end
        end
      end
    end

    @doc """
    The limit is decreased after a succesfully returned document, while
    the ids are updated after succesfully fetching the document.
    """
    def next_fun(barrel, query, proj) do
      fn
        state(limit: 0) = state ->
          {:halt, state}

        state(ids: []) = state ->
          {:halt, state}

        state(ids: ids, limit: limit) = state ->
          with {id, new_ids} <- ids |> List.pop_at(0),
               _ <- state(state, ids: new_ids) do
            case Document.fetch_one(barrel, id) do
              {:ok, doc} ->
                case satisfies_query(doc, query) do
                  true ->
                    with projected_doc <- satisfies_proj(doc, proj) do
                      {[projected_doc], state(state, limit: limit - 1)}
                    end

                  false ->
                    with empty_doc <- Map.new() do
                      {[empty_doc], state(state, limit: limit - 1)}
                    end
                end

              {:error, reason} ->
                raise reason
            end
          end
      end
    end

    @doc """
    In future, after remote connection, close it here.
    """
    defp after_fun(_) do
      fn state(state) ->
        :ok
      end
    end

    @spec satisfies_query(map, none()) :: boolean()
    defp satisfies_query(doc, nil), do: true

    @spec satisfies_query(map, Keyword.t()) :: boolean()
    defp satisfies_query(doc, query) do
      with query_keys <- Keyword.keys(query),
           # all doc keys that are affected by query keys
           doc_keys <- Keyword.take(doc, query_keys) do
        for k <- doc_keys do
          if doc_keys[k] != query_keys[k] do
            # TODO: add more rule-matching queries with $gt and $lt,...
            # at the moment, only equality is supported
            false
          end
        end
      end

      true
    end

    @spec get_projection(map()) :: list()
    defp get_projection(projection_map) do
      with all_keys_list <- Enum.filter(projection_map, fn {k, v} -> is_truthy(k, v) end),
           projectables <- Enum.reject(all_keys_list, &is_nil/1) do
        projectables
      end
    end

    @spec satisfies_proj(map(), map()) :: map()
    defp satisfies_proj(doc, projection) do
      with projectables <- get_projection(projection),
           final_doc <- doc |> Map.take(projectables) do
        final_doc
      end
    end

    @spec is_truthy(any, any) :: any
    defp is_truthy(k, v) do
      case v do
        1 ->
          k

        true ->
          k

        0 ->
          nil

        false ->
          nil

        other ->
          raise "invalid projection value: #{other}"
      end
    end

    def slice(_enum) do
      {:error, __MODULE__}
    end
  end
end
