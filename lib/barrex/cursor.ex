import Record
defmodule Barrex.Cursor do
  alias Barrex.{
    Document,
    Index
  }

  # Client

  @type t :: %__MODULE__{}

  defstruct [:data]

  defimpl Enumerable do
    defrecordp :state [:barrel, :limit, :cursor, :position]
    end

    def count(enum) do
      {:error, __MODULE__}
    end

    def member?(enum, elem) do
      {:error, __MODULE__}
    end

    def reduce(%{barrel: barrel, limit: limit}, acc, reduce_fun) do
      start_fun = start_fun(barrel, limit)
      next_fun = next_fun(barrel)
      after_fun = after_fun([])
      Stream.resource(start_fun, next_fun, after_fun)
    end

    def slice(enum) do
      {:error, __MODULE__}
    end

    # TODO: make cursor /id independent
    defp start_fun(barrel, limit) do
      case Index.query(barrel, "/id", fn doc, acc -> [doc["id"] | acc] end, [], %{}) do
        {:ok, indexes} ->
          state(barrel: barrel, limit: limit, cursor: indexes)

        {:error, reason} ->
          raise reason
      end
    end

    defp next_fun(barrel, opts \\ []) do
      case state.position >= limit or state.cursor |> Enum.at(state.position) |> is_nil() do
        true ->
          {:halt, state}
        _ ->
          nil
      end
      with doc <- state.cursor |> Enum.at(state.position) do
        
      end
      Document.find()
      {:elem, acc}
    end

    defp after_fun(_opts) do
      :ok
    end
  end
end
