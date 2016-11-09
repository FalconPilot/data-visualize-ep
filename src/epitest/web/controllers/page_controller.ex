defmodule Epitest.PageController do
  use Epitest.Web, :controller

  # Page display

  def index(conn, _params) do
    render conn, "index.html"
  end

  # Fetching request

  def fetch(conn, params) do
    # For debug purposes, load data if it exists
    data = get_json("priv/data/logs.json")
    url = "https://bugs-data.thomasdufour.fr:2847/0.1/modules"
    case request(url, params["fetch"]["login"], params["fetch"]["password"]) do
      {:ok, data} ->
        conn
        |> assign(:data, data)
        |> render("dataview.html")
      {:error, message} ->
        IO.inspect message
        redirect conn, to: "/"
      _ ->
        redirect conn, to: "/"
    end
  end

  # HTTP Request

  def request(url, login, password) do
    case HTTPoison.get(url, [], [hackney: [basic_auth: {login, password}]]) do
      {:ok, %HTTPoison.Response{status_code: 200, headers: headers, body: body}} ->
        {:ok, unzip(headers, body)}
      {:ok, %HTTPoison.Response{status_code: 401, headers: headers}} ->
        {:error, "Error 401 : Unauthorized !"}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Error 404 : not found !"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      other ->
        {:error, other}
    end
  end

  # Data fetching

  def unzip(headers, body) do
    :zlib.gunzip(body)
    |> Poison.decode!()
    |> List.first
  end

  def get_json(filename) do
    File.read!(filename)
    |> Poison.decode!()
  end

end
