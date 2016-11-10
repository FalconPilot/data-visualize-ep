defmodule Epitest.PageController do
  use Epitest.Web, :controller

  # Page display

  def index(conn, _params) do
    render conn, "index.html"
  end

  # Fetching request

  def fetch(conn, params) do
    root = "https://bugs-data.thomasdufour.fr:2847/0.1/modules"
    login = params["fetch"]["login"]
    pass = params["fetch"]["password"]
    params = %{burl: root, login: login, pass: pass}
    case request(root, login, pass) do
      {:ok, data} ->
        modules = get_list data, "code"
        projects = get_sub params, "name", modules
        IO.inspect map_from_lists(modules, projects)
        conn
        |> assign(:data, "Lel")
        |> render("dataview.html")
      {:error, message} ->
        IO.puts message
        redirect conn, to: "/"
    end
  end

  # Create map from lists

  def map_from_lists(list1, list2) do
    map_from_lists list1, list2, []
  end

  def map_from_lists([h1|t1], [h2|t2], acc) do
    map_from_lists t1, t2, [%{module: h1, projects: h2}|acc]
  end

  def map_from_lists([], [], acc) do
    Enum.reverse acc
  end

  # Get lists from keys

  def get_list(list, key) do
    get_list list, key, []
  end

  def get_list([h|t], key, acc) do
    get_list t, key, [h[key]|acc]
  end

  def get_list([], _key, acc) do
    Enum.reverse acc
  end

  # Get sub-lists

  def get_sub(params, key, modules) do
    get_sub params, key, modules, []
  end

  def get_sub(params, key, [h|t], acc) do
    get_sub params, key, t, [get_all_projects(params, key, h)|acc]
  end

  def get_sub(_params, _key, [], acc) do
    Enum.reverse acc
  end

  # Get all projects

  def get_all_projects(params, key, module) do
    url = "#{params.burl}/#{module}/projects"
    case request(url, params.login, params.pass) do
      {:ok, data} ->
        get_list data, "name"
      {:error, message} ->
        IO.puts message
        []
    end
  end

  # Get a single project test results

  def get_test_results(params, module, suffix) do
    url = "#{params.burl}/#{module}/projects/#{suffix}/testRuns/2015?before=2016-08-01T00:00:00Z"
    case request(url, params.login, params.pass) do
      {:ok, data} ->
        data
      {:error, message} ->
        IO.puts message
        %{}
    end
  end

  # Update results

  def update_results(map, key) do
    Map.update map, key, 1, &(&1 + 1)
  end

  # HTTP Request

  def request(url, login, password) do
    case HTTPoison.get(url, [], [hackney: [basic_auth: {login, password}]]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, unzip(body)}
      {:ok, %HTTPoison.Response{status_code: num}} ->
        msg = """
        Code #{num} !
        -> #{url}
        """
        {:error, msg}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      other ->
        {:error, other}
    end
  end

  # Data fetching

  def unzip(body) do
    :zlib.gunzip(body)
    |> Poison.decode!()
  end

  def get_json(filename) do
    File.read!(filename)
    |> Poison.decode!()
  end

end
