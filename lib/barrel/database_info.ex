defmodule Barrel.DatabaseInfo do
  use GenServer

  ### CLIENT API

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: :database_info)
  end

  def add(name) do
    GenServer.call(:database_info, {:add, name})
  end

  def delete(name) do
    GenServer.call(:database_info, {:delete, name})
  end

  def show do
    GenServer.call(:database_info, {:show})
  end

  ### SERVER API

  def init(args) do
    {:ok, %{}}
  end

  def handle_call({:add, name}, _from, names) do
    {:reply, name, Map.put(names, name, 1)}
  end

  def handle_call({:delete, name}, _from, names) do
    {:reply, name, Map.delete(names, name)}
  end

  def handle_call({:show}, _from, names) do
    {:reply, names, names}
  end
end
