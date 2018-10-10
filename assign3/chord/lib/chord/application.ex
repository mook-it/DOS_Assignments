defmodule Chord.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Chord.Worker.start_link(arg)
      # {Chord.Worker, arg},
      Chord.NodeSupervisor,
      {Chord.Driver, {20, 25, 0}}
    ]

    opts = [strategy: :one_for_one, name: Chord.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
