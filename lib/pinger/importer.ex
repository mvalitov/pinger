defmodule Pinger.Importer do
  use GenStage
  require Logger
  alias Pinger.Downloader

  def start_link(id) do
    GenStage.start_link(__MODULE__, id, name: :"#{__MODULE__}#{id}")
  end

  def init(id) do
    Logger.debug "#{inspect(self())} IMPORTER init #{inspect(id)}"
    {:producer_consumer, id, subscribe_to: [{Pinger.Loader, max_demand: 1, min_demand: 0}]}
  end

  def handle_events([group], from, id) do
    Logger.debug "#{inspect(self())} IMPORTER handle_events #{inspect(group)} from #{inspect(from)}, #{inspect(id)}"
    proxies =
      Downloader.download(group)
      |> generate_proxies(group.id)
    {:noreply, proxies, id}
  end

  defp generate_proxies list, id do
    Enum.reduce(list, [], fn(x, acc) ->
      List.insert_at(acc, -1, %Pinger.Proxy{group_id: id, url: x})
    end)
  end

end
