defmodule Epitest.PageView do
  use Epitest.Web, :view

  # Parsing data

  def fetch_data(data, [h|t], acc) do
    case is_list(data[h]) do
      true ->
        fetch_data(data, t, [acc|fetch_data(data, h, "")])
      _ ->
        fetch_data(data, t, [acc|h])
    end
    case is_map(data[h]) do
      true ->
        fetch_data(data, t, [acc|fetch_data(data, h, "")])
      _ ->
        fetch_data(data, t, [acc|h])
    end
  end

  # Out of data

  def fetch_data(data, _, acc) do
    acc
  end

  def fetch_data(data) do
    fetch_data(data, Map.keys(data), "")
  end

end
