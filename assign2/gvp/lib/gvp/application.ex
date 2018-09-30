defmodule Gvp.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Gvp.Worker.start_link(arg)
      # {Gvp.Worker, arg},
      Gvp.Topologies,
      Gvp.Gossip.NodeSupervisor,
      {Gvp.Gossip.Driver, {100000, "2D"}}

    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_all, name: Gvp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
