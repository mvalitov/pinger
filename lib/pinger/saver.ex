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
        {:"Elixir.Pinger.Pinger#{id}", max_demand: Application.get_env(:pinger, :max_demand), min_demand: Application.get_env(:pinger, :min_demand)}
      end
    {:consumer, conn, subscribe_to: pingers}
  end

  def handle_events(events, _from, conn) do
    for event <- events do
      Pinger.Proxy.save(event, conn)
      Logger.info "#{inspect(event)} is OK"
    end
    {:noreply, [], conn}
  end

end
