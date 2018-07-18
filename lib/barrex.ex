defmodule Barrex do
  @moduledoc """
  Documentation for Barrex.
  """

  alias Barrex.Connection

  def start_link(opts \\ %{}) do
    with :ok <- config(),
         {:ok, _} <- Application.ensure_all_started(:barrel),
         {:ok, _} <- :barrel_store_sup.start_store(:default, :barrel_memory_storage, %{}) do
      opts
      |> Connection.start_link()

      # {:ok, spawn(fn _ -> :dummy end)}
    end
  end

  def start(_app, _opts) do
    start_link()
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
