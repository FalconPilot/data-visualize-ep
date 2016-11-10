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
    password = params["fetch"]["password"]
    case request(root, login, password) do
      {:ok, data} ->
        results = %{}
        Enum.each(data, fn(module) ->
          mname = module["code"]
          Enum.each(module["projects"], fn(project) ->
            pname = project["name"]
            Enum.each(["2014", "2015", "2016"], fn(date) ->
              url = "#{root}/#{mname}/projects/#{pname}/testRuns/2016?before=#{date}-11-10T00:00:00Z"
              case request(url, login, password) do
                {:ok, sub} ->
                  Enum.each(sub, fn(skills) ->
                    Enum.each(skills["skills"], fn(tests) ->
                      Enum.each(tests["tests"], fn(test) ->
                        case test do
                          %{"passed" => false, "mandatory" => false} ->
                            Map.update results, :fail_opt, 1, &(&1 + 1)
                          %{"passed" => true, "mandatory" => false} ->
                            Map.update results, :pass_opt, 1, &(&1 + 1)
                          %{"passed" => false, "mandatory" => true} ->
                            Map.update results, :fail_man, 1, &(&1 + 1)
                          %{"passed" => true, "mandatory" => true} ->
                            Map.update results, :pass_man, 1, &(&1 + 1)
                          _ ->
                            IO.puts "Ngueh ?"
                        end
                      end)
                    end)
                  end)
                {:error, msg} ->
                  IO.puts msg
              end
            end)
          end)
        end)
        IO.inspect results
        conn
        |> assign(:data, results)
        |> render("dataview.html")
      {:error, message} ->
        IO.puts message
        redirect conn, to: "/"
      _ ->
        redirect conn, to: "/"
    end
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
