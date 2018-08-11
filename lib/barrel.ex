defmodule Barrel do
  @moduledoc """
  Documentation for Barrel. Meant to run under a Supervisor.
  """
  # use Application

  alias Barrel.Connection

  def start_link(address, port, opts \\ %{}) do
    # TODO: maybe use start_link and add barrel in a supervision tree?
    # with :ok <- config(),
    #      {:ok, _} <- Application.ensure_all_started(:barrel),
    #      {:ok, _} <- :barrel_store_provider_sup.start_store(:default, :barrel_memory_storage, %{}) do
    #   Connection.start_link(address, port, opts)
    # end
    Connection.start_link(address, port, opts)
  end

  def stop(_app) do
    :ok = Application.stop(:barrel)
  end

  def config do
    Application.put_env(:barrel, :stores, [])
    Application.put_env(:barrel, :data_dir, "data")
    Application.put_env(:barrel, :ts_file, "BARREL_TS")
    Application.put_env(:barrel_stats, :update_interval, 500)

    :ok
  end

  # TODO: defdelegates to document, database and index modules?
end
