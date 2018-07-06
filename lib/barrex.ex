defmodule Barrex do
  @moduledoc """
  Documentation for Barrex.
  """

  use Application

  def start(_app, _type) do
    :ok = config()
    {:ok, _} = Application.ensure_all_started(:barrel)
    {:ok, _} = :barrel_store_sup.start_store(:default, :barrel_memory_storage, %{})
  end

  def stop(_app) do
    # :ok = :barrel_store_sup.stop_store(:default)
    :ok = Application.stop(:barrel)
  end

  def config do
    Application.put_env(:barrel, :stores, [])
    Application.put_env(:barrel, :data_dir, "data")
    Application.put_env(:barrel, :ts_file, "BARREL_TS")
    Application.put_env(:barrel_stats, :update_interval, 500)

    :ok
  end
end
