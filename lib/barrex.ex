defmodule Barrex do
  @moduledoc """
  Documentation for Barrex.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Barrex.hello
      :world

  """
  use Application

  def start(_type, _args) do
    {:ok, _} = Application.ensure_all_started(:barrel)
    {:ok, _} = :barrel_store_sup.start_store(:default, :barrel_memory_storage, %{})
    # Barrex.DatabaseInfoSupervisor.start_link(name: DBInfo)
  end

  def hello do
    :world
  end
end
