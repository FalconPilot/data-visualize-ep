defmodule Epitest.PageController do
  use Epitest.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
