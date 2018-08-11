defmodule Barrel.Database do
  @moduledoc """
  Module for database creation, destruction and info.
  """
  alias Barrel.DatabaseInfo

  @type barrel :: String.t()

  @type store :: atom()

  @type status :: atom()

  @type message :: atom() | Info.t()

  defmodule Info do
    @moduledoc """
    Module for representing the Barrel
    database info return value.
    """
    @type t :: %__MODULE__{
            docs_count: any(),
            del_docs_count: any(),
            id: any(),
            indexed_seq: any(),
            name: any(),
            store: any(),
            tab: any(),
            updated_seq: any()
          }

    defstruct [:docs_count, :del_docs_count, :id, :indexed_seq, :name, :store, :tab, :updated_seq]
  end

  defmodule Options do
    @moduledoc """
    Options for database creation. Use to override the optional
    params for the child spec for the database supervisor.
    (http://erlang.org/doc/design_principles/sup_princ.html#child-specification)
    """
    @type t :: %__MODULE__{
            restart: any(),
            shutdown: any(),
            type: any(),
            modules: any()
          }

    defstruct [:restart, :shutdown, :type, :modules]
  end

  @doc """
  List all barrels in the default store.

  TODO: reimplement after store changes.
  """
  @spec all() :: pid
  def all do
    with stores <- Application.fetch_env!(:barrel, :stores),
         default <- stores |> Enum.at(0) |> Tuple.to_list() |> Enum.at(0),
         store_pid <- :barrel_store_provider.get_provider(default) do
      :barrel_store_provider.get_provider_barrels(store_pid)
    end
  end

  @doc """
  List all barrels in a given `store`.

  TODO: reimplement after store changes.
  """
  @spec all(store) :: pid
  def all(store) do
    with store_pid <- :barrel_store_provider.get_provider(store) do
      :barrel_store_provider.get_provider_barrels(store_pid)
    end
  end

  @doc """
  Create a barrel, (note: for now options are an empty map).
  """
  @spec create(barrel) :: {status, message}
  def create(name) do
    create(name, %Options{})
  end

  @spec create(barrel, Options.t() | none) :: {status, message}
  def create(name, %Options{} = options) do
    with opts <- Map.from_struct(options) do
      case :barrel.create_barrel(name, opts) do
        :ok ->
          DatabaseInfo.add(name)
          {:ok, :created}

        {:error, :already_exists} ->
          {:error, :already_exists}

        {:error, _reason} ->
          {:error, :unknown}
      end
    end
  end

  @doc """
  Delete a barrel.
  """
  @spec delete(barrel) :: {status, message}
  def delete(name) do
    case :barrel.drop_barrel(name) do
      :ok ->
        {:ok, :deleted}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Return barrel_infos.
  Output example:
  iex(7)> Database.info(n)
    
    %{
      docs_count: 0,
      id: "7f91b75681b04049baced7d7adab135e",
      indexed_seq: 0,
      name: "my_db_jakub",
      store: :default,
      tab: :default_my_db_jakub,
      updated_seq: 0
    }
  """
  @spec info(barrel) :: {status, message}
  def info(barrel) do
    case :barrel.barrel_infos(barrel) do
      {:error, reason} ->
        {:error, reason}

      db_info when is_map(db_info) ->
        with info <- db_info |> Map.to_list(),
             info2 <- struct!(Info, info) do
          {:ok, info2}
        end
    end
  end

  @spec exists?(barrel) :: boolean()
  def exists?(barrel) do
    case info(barrel) do
      {:ok, _info} ->
        true

      {:error, :not_found} ->
        false
    end
  end
end
