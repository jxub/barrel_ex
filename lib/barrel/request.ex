defmodule BarrelEx.Request do
  use HTTPoison.Base

  @endpoint "http://localhost:7080/"

  # @fields

  def process_url(url) do
    @endpoint <> url
  end

  def process_request_body(body) do
    Poison.encode!(body)
  end

  def process_response_body(body) do
    Poison.decode!(body)
  end

  # def process_response_body(body) do
  # implement fields access
  # end
  """
  alias BarrelEx.{
    Database,
    Database.Document
  }
  with {:ok, db} = Database.get(db) do
    %{"id": "1234", "name": "Jakub", "surname": "Janarek"}
    |> Document.create!(db)
  end
  """
end
