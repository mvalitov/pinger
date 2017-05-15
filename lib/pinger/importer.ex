defmodule Pinger.Importer do
  use GenStage
  require Logger
  alias Pinger.Downloader

  def start_link(id) do
    GenStage.start_link(__MODULE__, id, name: :"#{__MODULE__}#{id}")
  end

  def init(id) do
    Logger.debug "#{inspect(self())} IMPORTER init #{inspect(id)}"
    {:ok, conn} = Redix.start_link(host: Application.get_env(:pinger, :redis_host), port: Application.get_env(:pinger, :redis_port))
    {:producer_consumer, conn, subscribe_to: [{Pinger.Loader, max_demand: 1, min_demand: 0}]}
  end

  def handle_events([group], from, conn) do
    Logger.debug "#{inspect(self())} IMPORTER handle_events #{inspect(group)} from #{inspect(from)}, #{inspect(conn)}"
    proxies =
      Downloader.download(group)
      |> generate_proxies(group.id)
    save_count(conn, Enum.count(proxies), group.id)
    {:noreply, proxies, conn}
  end

  defp generate_proxies list, id do
    for l <- list do
      %Pinger.Proxy{group_id: id, url: l}
    end
  end

  defp save_count(conn, count, group_id) do
    Redix.command(conn, ["SET", "proxy|count|group_#{group_id}", count])
  end

end
