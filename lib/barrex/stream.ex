defmodule Barrex.Stream do
  @moduledoc """
  Module for streams.

  Usage:

  stream = Stream.new("my_db")

  Stream.subscribe(stream)
  """
  @enforce_keys [:barrel]
  defstruct barrel: nil, since: 0, interval: 100

  @typedoc """
  The type `stream` represents a barrel stream.
  TODO: check if default fields allow structs with
  other interval values to pass the spec.
  """
  @type stream :: %__MODULE__{}

  @typedoc """
  The type `ret_stream` is the return type after stream subscription.
  """
  @type ret_stream :: {atom(), atom() | map(), map()}

  @doc """
  Convenience function to create a new stream from
  the barrel `barrel` with an update interval `interval`.
  """
  @spec new(String.t(), integer(), integer()) :: stream()
  def new(barrel, since \\ 0, interval \\ 100) do
    %__MODULE__{barrel: barrel, since: since, interval: interval}
  end

  @doc """
  Gets the name of the barrel of the given `stream`.
  """
  @spec barrel(stream()) :: String.t()
  def barrel(stream) do
    stream
    |> Map.fetch!(:barrel)
  end

  @doc """
  Gets the options of the `stream` struct.
  """
  @spec options(stream()) :: map()
  def options(stream) do
    stream
    |> Map.drop([:barrel])
  end

  @doc """
  Subscribe to a stream to receive live updates about
  the changes in the database.
  Receives changes since the moment 0 by default.
  TODO: implement as a macro with context so there's no
  need to call unsubscribe when calling with `with` (?)
  """
  @spec subscribe(stream()) :: {atom(), atom() | map(), map()}
  def subscribe(stream) do
    with barrel = barrel(stream),
         options = options(stream) do
      :barrel.subscribe_changes(barrel, options)
    end
  end

  @spec subscribe(stream(), pid()) :: {atom(), atom() | map(), map()}
  def subscribe(stream, pid) do
    with barrel = barrel(stream),
         options = options(stream) do
      :barrel.subscribe_changes(barrel, pid, options)
    end
  end

  @doc """
  Subscribe to a stream on a remote node to receive
  live updates about the changes in the database.
  Receives changes since the moment 0 by default.
  TODO: implement as a macro, grabbing the pid from the outer code
  and supplying since = 0 by default.
  TODO: Maybe even call unsubscribe automatically when the block of code
  where the macro is called ends.
  """
  @spec subscribe(node(), stream(), pid()) :: {atom(), atom() | map(), map()}
  def subscribe(node, stream, pid) do
    with barrel = barrel(stream),
         options = options(stream) do
      :barrel.subscribe_changes(node, barrel, pid, options)
    end
  end

  @doc """
  Unsubscribe and stop receiving changes from the remote database.
  """
  @spec unsubscribe(stream()) :: atom()
  def unsubscribe(stream) do
    stream
    |> drop_interval()
    |> :barrel.unsubscribe_change()
  end

  @doc """
  Unsubscribe and stop receiving changes from the remote database.
  """
  @spec unsubscribe(stream(), pid()) :: atom()
  def unsubscribe(stream, pid) do
    stream
    |> drop_interval()
    |> :barrel.unsubscribe_change(pid)
  end

  @doc """
  Unsubscribe and stop receiving changes from
  the remote database on another node.
  """
  @spec unsubscribe(node(), stream(), pid()) :: atom()
  def unsubscribe(node, stream, pid) do
    stream = stream |> drop_interval()
    :barrel.unsubscribe_change(node, stream, pid)
  end

  def drop_interval(stream) do
    stream
    |> IO.inspect
    |> Map.drop([:since, :__struct__])
  end
end
