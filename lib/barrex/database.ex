defmodule Barrex.Database do
  @moduledoc """
  Module for database creation, destruction and info.
  """

  defmodule Info do
    @moduledoc """
    Module for representing the Barrel
    database info return value.
    """
    @type t :: __MODULE__

    defstruct [:docs_count, :id, :indexed_seq,
      :name, :store, :tab, :updated_seq]
  end

  defmodule Options do
    @moduledoc """
    Options for database creation. Use to override the optional
    params for the child spec for the database supervisor.
    (http://erlang.org/doc/design_principles/sup_princ.html#child-specification)
    """
    @type t :: __MODULE__

    defstruct restart: nil, shutdown: nil, type: nil, modules: nil
  end

  @doc """
  Create a barrel, (note: for now the options is an empty map).
  """
  @spec create(String.t) :: {atom, atom}
  def create(name), do: create(name, %Options{})

  @spec create(String.t, map | none) :: {atom, atom}
  def create(name, %Options{} = options) do
    with opts <- Map.from_struct(options) do
      case :barrel.create_barrel(name, opts) do
        :ok ->
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
  @spec delete(String.t) :: {atom, atom}
  def delete(name) do
    case :barrel.delete_barrel(name) do
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
  @spec info(String.t) :: {atom, atom | Info.t}
  def info(name) do
    case :barrel.barrel_infos(name) do
      {:error, reason} ->
        {:error, reason}

      db_info when is_map(db_info) ->
        {:ok, db_info}
    end
  end
end
