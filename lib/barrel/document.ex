defmodule BarrelEx.Document do
  alias BarrelEx.Request

  @type status :: atom()
  @type map :: %{optional(any) => any}

  # @spec get(String.t) :: {status, map}
  def get(db) do
    db
    |> make_url()
    |> Request.get()
  end

  # @spec get!(String.t) :: map
  def get!(db) do
    db
    |> make_url()
    |> Request.get!()
  end

  @doc """
  %{
    "x-barrel-id-match" => x_barrel_id_match,
    "since" => since,
    "max" => max,
    "lte" => lte,
    "lt" => lt,
    "gte" => gte,
    "gt" => gt,
    "A-IM" => a_im
  }
  """
  # @spec get(String.t, map) :: {status, map}
  def get(db, options) when is_map(options) do
    with options = Map.to_list(options) do
      options = Enum.map(options, fn {k, v} -> {String.to_atom(k), v} end)
      get(db, options)
    end
  end

  # @spec get(String.t, list()) :: {status, map}
  def get(db, options) when is_list(options) do
    do_get(db, options)
  end

  @doc """
  If map has no id field, uuid is created instead.
  {
    "bla_value": "aaa",
    "id": "14bb7bfb-b658-4b35-bc73-667d18ccef9c"
  }
  """
  # @spec create(String.t, map) :: {status, map}
  def create(db, doc \\ %{}) do
    with url = make_url(db) do
      Request.post(url, doc)
    end
  end

  # @spec create!(String.t, map) :: map
  def create!(db, doc \\ %{}) do
    with url = make_url(db),
      Request.post!(url, doc)
    end
  end

  # @spec delete(String.t, map) :: {status, map}
  def delete(db, doc) when is_map(doc) do
    delete(db, doc["id"])
  end

  # @spec create(String.t, String.t) :: {status, map}
  def delete(db, doc_id) do
    with url = make_url(db, doc_id) do
      Request.delete(url)
    end
  end


  # @spec delete!(String.t, String.t) :: map
  def delete!(db, doc_id) do
    with url = make_url(db, doc_id) do
      Request.delete!(url)
    end
  end

  defp make_url(db) do
    "dbs/" <> db <> "/docs/"
  end

  defp make_url(db, doc_id) do
    make_url(db) <> doc_id
  end

  defp decode!(resp) do
    Poison.decode!(resp.body)
  end

  defp decode(resp) do
    case Poison.decode(resp.body) do
      {:ok, data} ->
        {:ok, data}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_get(db, options) do
    with url = make_url(db) do
      case Request.get(url, [], params: options) do
        {:ok, resp} -> Poison.decode(resp.body)
        {:error, reason} -> {:error, reason}
      end
    end
  end 
end
