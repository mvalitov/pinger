defmodule Pinger.Request do
  require Logger
  def ping(%{url: url, proxy: proxy, options: options}) do
    uri = URI.parse(proxy)
    params =
      case uri.scheme do
        "socks5" -> default_params(options["timeout"]*1000) ++ [proxy: {:socks5, String.to_charlist(uri.host), uri.port}]
        _-> default_params(options["timeout"]*1000) ++ [proxy: String.to_charlist(proxy)]
      end
    case HTTPoison.request(:get, String.to_charlist(url), "", [], params) do
      {:ok, response} ->
        %HTTPoison.Response{body: body, headers: list, status_code: integer} = response
        Poison.Parser.parse!(body)
      {:error, reason} ->
        reason
    end
  end

# timeout in milliseconds
  defp default_params(timeout \\ 5000) do
    [ssl: [verify: :verify_none], timeout: timeout, recv_timeout: timeout, connect_timeout: timeout]
  end

end
