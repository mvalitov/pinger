defmodule Pinger.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @max_importers 1
  @max_pingers 1
  @max_savers 1

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    loader = [
      worker(Pinger.Loader, [])
    ]

    importers =
      for i <- 1..@max_importers do
        worker(Pinger.Importer, [i], id: i)
      end

    pingers =
      for i <- 1..@max_pingers do
        worker(Pinger.Pinger, [{i, @max_importers}], id: i+@max_importers)
      end

    savers =
      for i <- 1..@max_savers do
        worker(Pinger.Saver, [@max_pingers], id: i+@max_importers+@max_pingers)
      end

    children = [
      # Starts a worker by calling: Pinger.Worker.start_link(arg1, arg2, arg3)
      # worker(Pinger.Worker, [arg1, arg2, arg3]),
    ]

    repo_sup = [supervisor(Pinger.Repo, [])]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pinger.Supervisor]
    Supervisor.start_link(repo_sup ++ loader ++ importers ++ pingers ++ savers, opts)
    # Supervisor.start_link(repo_sup, opts)
  end
end
