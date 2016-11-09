defmodule Epitest.PageController do
  use Epitest.Web, :controller

  def index(conn, _params) do
    conn
    |> render "index.html"
  end

  def fetch(conn, _params) do
    url = "https://bugs-data.thomasdufour.fr:2847/0.1/modules?login=#{login}&pass=#{pass}"
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts "OK"
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Error 404 !"
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
      stuff ->
        IO.inspect stuff
    end
    redirect conn, to: "/"
  end

  def get_json(filename) do
    File.read!(filename) |> Poison.decode!()
  end

end
