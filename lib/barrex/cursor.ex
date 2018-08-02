require Record

defmodule Barrex.Cursor do
  alias Barrex.{
    Document,
    Index
  }

  # Client

  @type t :: %__MODULE__{
          barrel: String.t(),
          limit: integer(),
          opts: Keyword.t()
        }

  defstruct [:barrel, :limit, :opts]

  defimpl Enumerable do
    Record.defrecordp(:state, barrel: nil, limit: nil, cursor: nil, position: 0)

    def count(enum) do
      {:error, __MODULE__}
    end

    def member?(enum, elem) do
      {:error, __MODULE__}
    end

    def reduce(%{barrel: barrel, limit: limit, opts: opts}, acc, reduce_fun) do
      start_fun = start_fun(barrel, limit)
      next_fun = next_fun(barrel, limit, opts)
      after_fun = after_fun([])
      Stream.resource(start_fun, next_fun, after_fun).(acc, reduce_fun)
    end

    def slice(enum) do
      {:error, __MODULE__}
    end

    defp start_fun(barrel, limit) do
      case Index.ids(barrel) do
        {:ok, indexes} ->
          state(barrel: barrel, limit: limit, cursor: indexes, position: 0)

        {:error, reason} ->
          raise reason
      end
    end

    defp next_fun(barrel, limit, opts \\ %{}) do
      with id <- state.cursor |> Enum.at(state.position) do
        if state.position > limit do
          {:halt, state(state)}
        end

        case id do
          nil ->
            {:halt, state(state)}

          _ ->
            fetch_next(id, barrel, limit, opts)
        end
      end
    end

    defp fetch_next(id, barrel, limit, opts) do
      case Document.fetch(barrel, id, opts) do
        {:ok, doc} ->
          {doc, state(state, position: state.position + 1)}

        {:error, reason} ->
          raise reason
      end
    end

    defp after_fun(_opts) do
      :ok
    end
  end
end
