defmodule Barrex.Cursor do
  alias Barrex.{
    Index
  }

  # Client

  @type t :: %__MODULE__{}

  defstruct [:data]

  defimpl Enumerable do
    def count(enum) do
      {:error, __MODULE__}
    end

    def member?(enum, elem) do
      {:error, __MODULE__}
    end

    def reduce(enum, acc, fun) do
      Stream.resource(&start_fun/0, &next_fun/1, &after_fun/1)
    end

    def slice(enum) do
      {:error, __MODULE__}
    end

    defp start_fun() do
      []
    end

    defp next_fun(acc) do
      {:elem, acc}
    end

    defp after_fun(acc) do
      acc
    end
  end
end
