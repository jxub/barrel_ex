defmodule Barrex.DatabaseInfo do
  use GenServer

  ### CLIENT API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def add(pid, name) do
    GenServer.call(pid, {:add, name})
  end

  def delete(pid, name) do
    GenServer.call(pid, {:delete, name})
  end

  def show(pid) do
    GenServer.call(pid, {:show})
  end

  ### SERVER API

  def init(:ok) do
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