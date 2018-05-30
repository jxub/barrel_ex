defmodule Barrex.Database do
  alias Barrex.DatabaseInfo

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

  @spec info(String.t()) :: {String.t(), non_neg_integer(), non_neg_integer(), non_neg_integer()}
  def info(name) do
    :barrel.barrel_infos(name)
  end
end