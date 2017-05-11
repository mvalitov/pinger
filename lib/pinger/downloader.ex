defmodule Pinger.Downloader do
  require Logger
  def download(group) do
    Logger.debug "#{inspect(self())} Download new proxy list, link #{group.url}"
    %HTTPoison.Response{body: body} = HTTPoison.get!(group.url)
    String.split(body, "\n")
    |> Enum.map(fn(x) -> "#{group.scheme}://" <> String.trim(x) end)
  end

end
