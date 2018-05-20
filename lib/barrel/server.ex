defmodule BarrelEx.Server do
  @moduledoc """
  Gives information about Barrel version,
  object ID's and access to the documentation.
  """
  alias BarrelEx.Request

  @doc """
  Information about Barrel-db version,
  the description of the Barrel-db application
  and the URI location of the API doc alongside
  the request status.
  """
  @spec info(none()) :: {atom(), map()}
  def info do
    Request.get()
  end

  @doc """
  Information about Barrel-db version,
  the description of the Barrel-db application
  and the URI location of the API doc.
  """
  @spec info!(none()) :: map
  def info! do
    Request.get!()
  end

  @doc """
  Returns a new K-Ordered 16-bytes object ID and
  the request status.
  """
  @spec ids(none()) :: {atom(), map()}
  def ids do
    Request.get("/ids")
  end

  @doc """
  Returns a new K-Ordered 16-bytes object ID.
  """
  @spec ids!(none()) :: map
  def ids! do
    Request.get!("/ids")
  end
end
