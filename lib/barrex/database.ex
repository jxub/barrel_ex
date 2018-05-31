defmodule Barrex.Database do
  @moduledoc """
  Module for database creation, destruction and info.
  """

  # use Agent
  # alias Barrex.DatabaseInfo

  @doc """
  Create a barrel, (note: for now the options is an empty map).
  """
  # @spec create(String.t(), map() | none()) :: {atom(), String.t()}
  @spec create(String.t(), map() | none()) :: {atom(), atom()}
  def create(name, options \\ %{}) do
    case :barrel.create_barrel(name, options) do
      # :ok -> {:ok, DatabaseInfo.add(DBInfo, name)}
      # {:error, reason} -> {:error, Atom.to_string(reason)}
      :ok -> {:ok, :created}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Delete a barrel.
  """
  # @spec delete(String.t()) :: {atom(), String.t()}
  @spec delete(String.t()) :: {atom(), atom()}
  def delete(name) do
    case :barrel.delete_barrel(name) do
      # :ok -> {:ok, DatabaseInfo.delete(DBInfo, name)}
      # {:error, reason} -> {:error, Atom.to_string(reason)}
      :ok -> {:ok, :deleted}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Return barrel_infos.
  """
  @spec info(String.t()) :: {String.t(), non_neg_integer(), non_neg_integer(), non_neg_integer()}
  def info(name) do
    :barrel.barrel_infos(name)
  end
end