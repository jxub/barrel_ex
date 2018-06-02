defmodule Barrex.Stream do
  defstruct barrel: nil, interval: 100
end

defmodule Barrex.Streams do
  @moduledoc """
  Module for streams.
  """
  alias Barrex.Stream

  @typedoc """
  The type stream represents a barrel stream.
  TODO: check if default fields allow structs with
  other interval values to pass the spec.
  """
  @type stream :: %Stream{}

  @doc """
  Convenience function to create a new stream from
  the barrel `barrel` with an update interval `interval`.
  """
  def new(barrel, interval \\ 100) do
    %Stream{barrel: barrel, interval: interval}
  end

  @doc """
  Subscribe to a stream to receive live updates about
  the changes in the database.
  Receives changes since the moment 0 by default.
  TODO: implement as a macro with context so there's no
  need to call unsubscribe when calling with `with` (?)
  TODO: grab pid() from calling process by default
  """
  @spec subscribe(stream, pid(), integer()) :: {atom(), atom() | map(), map()}
  def subscribe(stream, pid, since) do
    :barrel_db_stream_mgr.subscribe(stream, pid, since)
  end

  @doc """
  Subscribe to a stream on a remote node to receive
  live updates about the changes in the database.
  Receives changes since the moment 0 by default.
  """
  @spec subscribe(stream, map(), pid(), integer()) :: {atom(), atom() | map(), map()}
  def subscribe(node, stream, pid, since) do
    :barrel_db_stream_mgr.subscribe(node, stream, pid, since)
  end

  @doc """
  Unsubscribe and stop receiving changes from the remote the database.
  """
  @spec unsubscribe(stream, pid()) :: {atom(), atom() | map(), map()}
  def unsubscribe(stream, pid) do
    :barrel_db_stream_mgr.unsubscribe(stream, pid)
  end

  @doc """
  Unsubscribe and stop receiving changes from the remote the database.
  """
  @spec unsubscribe(node(), stream, pid()) :: {atom(), atom() | map(), map()}
  def unsubscribe(node, stream, pid) do
    :barrel_db_stream_mgr.unsubscribe(node, stream, pid)
  end
end
