defmodule Gvpbonus.Application do
  use Application

  def start(type,args) do

    #IO.puts("in here2")
    children = [
      # Starts a worker by calling: Gvp.Worker.start_link(arg)
      # {Gvp.Worker, arg},
      Gvpbonus.Topologies,
      Gvpbonus.Gossip.NodeSupervisor,
      {Gvpbonus.Gossip.Driver, args}

    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_all, name: Gvpbonus.Supervisor]
    Supervisor.start_link(children, opts)
  end

end



