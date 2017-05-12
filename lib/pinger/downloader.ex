defmodule Pinger.Downloader do
  require Logger
  def download(group) do
    Logger.debug "#{inspect(self())} Download new proxy list, link #{group.url}"
    timeout = 30_000_000
    opts = [timeout: timeout, recv_timeout: timeout, connect_timeout: timeout, hackney: [pool: false]]
    %HTTPoison.Response{body: body} = HTTPoison.get!(group.url, [], opts)
    String.split(body, "\n")
    |> Enum.map(fn(x) -> "#{group.scheme}://" <> String.trim(x) end)
  end

end
