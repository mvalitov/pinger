defmodule Pinger.Loader do
  use GenStage
  require Logger
  alias Pinger.Group

  def start_link(initial \\ 0) do
    GenStage.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def init(_state) do
    groups = Group.enabled
    Logger.debug "#{inspect(self())} LOADER init #{inspect(groups)}"
    {:producer, groups}
  end

  def handle_demand(demand, []) do
    # Logger.debug("#{inspect(self())} LOADER empty handle_demand #{demand}")
    [head|tail] = Group.enabled
    {:noreply, [head], tail}
  end

  def handle_demand(demand, groups) do
    head = Enum.slice(groups, 0, demand)
    tail = Enum.slice(groups, demand, Enum.count(groups))
    # Logger.debug("#{inspect(self())} LOADER handle_demand #{demand}, #{inspect(head)}, left #{Enum.count(tail)}")
    {:noreply, head, tail}
  end

end
