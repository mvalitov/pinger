defmodule Pinger.Pinger do
  use GenStage
  require Logger

  def start_link({id, count}) do
    GenStage.start_link(__MODULE__, count, name: :"#{__MODULE__}#{id}")
  end

  def init(count) do
    Logger.debug "#{inspect(self())} PINGER init #{inspect(count)}"
    options = Pinger.Settings.by_name("pinger")
    importers =
      for i <- 1..count do
        {:"Elixir.Pinger.Importer#{i}", max_demand: Application.get_env(:pinger, :max_demand), min_demand: Application.get_env(:pinger, :min_demand)}
      end
    {:producer_consumer, options, subscribe_to: importers}
  end

  def handle_events(events, _from, options) do
    proxies =
      Enum.map(events, fn(event) -> ping(event, options.value["request"]) end)
      |> Enum.reject(fn(x) -> x == nil end)
    {:noreply, proxies, options}
  end

  defp ping(proxy, options) do
    ip = Pinger.Request.ping([proxy: proxy.url, options: options])
    case ip do
      %HTTPoison.Error{} ->
        Logger.info "#{inspect(proxy)} is BAD"
        nil
      %{} -> %{proxy | ip: ip["ip"]["ip"], country_code: ip["ip"]["country_code"], region_code: lookup(ip["ip"]["ip"]).region}
    end
  end

  defp lookup(ip) do
    IP2Location.lookup(ip)
  end

end
