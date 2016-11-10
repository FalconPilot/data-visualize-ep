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
    date = params["fetch"]["date"]
    case request(root, login, pass) do
      {:ok, data} ->
        params =
          %{burl: root,
            login: login,
            pass: pass,
            year: date["year"],
            date:
              %{month: date["month"],
                day: date["day"],
                hour: date["hour"],
                minute: date["minute"]}
            }
        data = get_list(data, "code")
        |> get_sub(params)
        |> get_test_results(params)
        |> merge_maps
        conn
        |> assign(:data, data)
        |> render("dataview.html")
      {:error, message} ->
        IO.puts message
        redirect conn, to: "/"
    end
  end

  # Merge maps list

  def flatten_map(list) do
    flatten_map list, []
  end

  def flatten_map([h|t], acc) do
    if is_list(h) do
      flatten_map t, flatten_map(h) ++ acc
    else
      flatten_map t, [h|acc]
    end
  end

  def flatten_map([], acc) do
    Enum.reverse acc
  end

  def merge_maps(list) do
    flatmap = flatten_map(list)
    merge_maps flatmap, %{}
  end

  def merge_maps([h|t], map) do
    merge_maps t, update_map(map, h)
  end

  def merge_maps([], map) do
    Map.merge(map, %{total: Enum.sum(Map.values(map))})
  end

  # Update map from patch

  def update_map(map, patch) do
    update_map(map, [:fail_nocrash, :fail_crash, :fail_unknown, :passed, :unknown], patch)
  end

  def update_map(map, [h|t], patch) do
    case patch[h] do
      nil ->
        update_map map, t, patch
      val ->
        update_map Map.update(map, h, 1, &(&1+val)), t, patch
    end
  end

  def update_map(map, [], _patch) do
    map
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

  # Get main list

  def get_sub(modules, params) do
    get_sub modules, params, []
  end

  def get_sub([h|t], params, acc) do
    get_sub t, params, [%{module: h, projects: get_all_projects(h, params)}|acc]
  end

  def get_sub([], _params, acc) do
    Enum.reverse acc
  end

  # Get all projects

  def get_all_projects(module, params) do
    url = "#{params.burl}/#{module}/projects"
    case request(url, params.login, params.pass) do
      {:ok, data} ->
        get_list data, "name"
      {:error, message} ->
        IO.puts message
        {:error, message}
    end
  end

  # Get a single project test results

  def get_test_results(list, params) do
    get_test_results list, params, []
  end

  def get_test_results([%{module: module, projects: list}|t], params, acc) do
    get_test_results t, params, [get_result(list, module, params)|acc]
  end

  def get_test_results([], _params, acc) do
    Enum.reverse acc
  end

  # Get results of a project list

  def get_result(list, module, params) do
    get_result list, module, params, []
  end

  def get_result([h|t], module, params, acc) do
    get_result t, module, params, [get_test(module, h, params)|acc]
  end

  def get_result([], _module, _params, acc) do
    Enum.reverse acc
  end

  def get_test(module, project, params) do
    intYear = Kernel.elem(Integer.parse(params.year), 0)
    date = format_date(params.date)
    url = "#{params.burl}/#{module}/projects/#{project}/testRuns/#{params.year}?before=#{intYear+1}-#{date.month}-#{date.day}T#{date.hour}:#{date.minute}:00Z"
    case request(url, params.login, params.pass) do
      {:ok, data} ->
        get_grades data
      {:error, message} ->
        IO.puts message
        []
    end
  end

  # Format date params

  def format_date(map) do
    format_date Map.keys(map), map
  end

  def format_date([h|t], map) do
    if byte_size(map[h]) == 1 do
      newint = "0" <> map[h]
    else
      newint = map[h]
    end
    format_date t, Map.put(map, h, newint)
  end

  def format_date([], map) do
    map
  end

  # Get test grades

  def get_grades(list) do
    get_grades list, %{}
  end

  def get_grades([%{"tests" => tests}|t], acc) do
    get_grades t, Map.merge(parse_results(tests), acc)
  end

  def get_grades([%{"skills" => skills}|t], acc) do
    get_grades t, Map.merge(get_grades(skills), acc)
  end

  def get_grades([], acc) do
    acc
  end

  # Parse grade results

  def parse_results(list) do
    parse_results list, %{}
  end

  def parse_results([h|t], acc) do
    case h do
      %{"passed" => false, "crashed" => false} ->
        parse_results t, Map.update(acc, :fail_nocrash, 1, &(&1+1))
      %{"passed" => false, "crashed" => true} ->
        parse_results t, Map.update(acc, :fail_crash, 1, &(&1+1))
      %{"passed" => false} ->
        parse_results t, Map.update(acc, :fail_unknown, 1, &(&1+1))
      %{"passed" => true} ->
        parse_results t, Map.update(acc, :passed, 1, &(&1+1))
      _ ->
        parse_results t, Map.update(acc, :unknown, 1, &(&1+1))
    end
  end

  def parse_results([], acc) do
    acc
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
