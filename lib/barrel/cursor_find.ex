require Record

defmodule Barrel.Cursor do
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

  defstruct barrel: nil,
            query: %{},
            proj: %{},
            opts: %{}

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

        case get_id_or_ids(query) do
          nil ->
            # get all document id's if no id's supplied
            case Document.ids(barrel) do
              {:ok, ids} ->
                state(ids: ids, limit: limit) |> IO.inspect

              {:error, reason} ->
                raise reason
            end

          id_or_ids ->
            state(ids: id_or_ids, limit: limit) |> IO.inspect
        end
      end
    end

    @spec get_id_or_ids(map()) :: list()
    defp get_id_or_ids(query) do
      # prioritize :id in query to use also to find one doc
      case query[:id] do
        nil ->
          case query[:ids] do
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

        state(ids: ids, limit: limit) = state ->
          with {id, new_ids} <- ids |> List.pop_at(0),
               _ <- state(state, ids: new_ids) do
            case Document.fetch_one(barrel, id) do
              {:ok, doc} ->
                case satisfies_query(doc, query) do
                  true ->
                    with projected_doc <- satisfies_proj(doc, proj) do
                      {[projected_doc], state(state, limit: update_limit(limit))}
                    end

                  false ->
                    with empty_doc <- Map.new() do
                      {[empty_doc], state(state, limit: update_limit(limit))}
                    end
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
    If there is no limit set, do not decrement it.
    """
    defp update_limit(limit) do
      case limit do
        nil -> nil
        l when is_integer(l) -> l - 1
      end
    end

    @doc """
    In the future, after remote connection is implemented in barrel,
    close it here.
    """
    defp after_fun(_) do
      fn
        state(state) ->
          :ok
        res ->
          IO.inspect(res)
          :ok
      end
    end

    @spec satisfies_query(map, none()) :: boolean()
    defp satisfies_query(doc, nil), do: true

    @spec satisfies_query(map, map) :: boolean()
    defp satisfies_query(doc, query) do
      with query_keys <- Map.keys(query),
           # all doc keys that are affected by query keys
           doc_keys <- Map.take(doc, query_keys) do
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
