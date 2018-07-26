defmodule Barrex do
  @moduledoc """
  Documentation for Barrex.
  """

  alias Barrex.Connection

  def start_link(address \\ "127.0.0.1", port \\ 6000, opts \\ %{}) do
    with :ok <- config(),
         {:ok, _} <- Application.ensure_all_started(:barrel),
         {:ok, _} <- :barrel_store_sup.start_store(:default, :barrel_memory_storage, %{}) do
      Connection.start_link(address, port, opts)
    end
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
end
