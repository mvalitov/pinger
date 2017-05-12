defmodule Pinger.Saver do
  use GenStage
  require Logger

  def start_link(count) do
    GenStage.start_link(__MODULE__, count)
  end

  def init(count) do
    Logger.debug "#{inspect(self())} SAVER init #{inspect(count)}"
    {:ok, conn} = Redix.start_link(host: Application.get_env(:pinger, :redis_host), port: Application.get_env(:pinger, :redis_port))
    pingers =
      for id <- 1..count do
        {:"Elixir.Pinger.Pinger#{id}", max_demand: 5, min_demand: 0}
      end
    {:consumer, conn, subscribe_to: pingers}
  end

  def handle_events(events, _from, conn) do
    for event <- events do
      save_proxy(event, conn)
      Logger.info "#{inspect(event)} is OK"
    end
    {:noreply, [], conn}
  end

  defp save_proxy(proxy, conn) do
    json = Poison.encode!(proxy)
    {:ok, group_queue} = RedisUniqueQueue.create("proxy|groups|group_#{proxy.group_id}", conn)
    RedisUniqueQueue.push(group_queue, json)
    {:ok, country_queue} = RedisUniqueQueue.create("proxy|countries|#{proxy.country_code}", conn)
    RedisUniqueQueue.push(country_queue, json)
  end

end
