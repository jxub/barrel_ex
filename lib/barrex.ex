defmodule Barrex do
  @moduledoc """
  Documentation for Barrex.
  """
  
  use Application

  def start(_type, _args) do
    {:ok, _} = Application.ensure_all_started(:barrel)
    {:ok, _} = :barrel_store_sup.start_store(:default, :barrel_memory_storage, %{})
  end
end
