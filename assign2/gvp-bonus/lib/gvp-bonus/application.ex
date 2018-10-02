defmodule Gvpbonus.Application do
  use Application

  def start(_type, {numNodes, topology, algorithm, failure, start_time}) do
    children =
      if algorithm == "gossip" do
        [
          Gvpbonus.Topologies,
          Gvpbonus.Gossip.NodeSupervisor,
          {Gvpbonus.Gossip.Driver, {numNodes, topology, failure, start_time}}
        ]
      else
        [
          Gvpbonus.Topologies,
          Gvpbonus.PushSum.NodeSupervisor,
          {Gvpbonus.PushSum.Driver, {numNodes, topology, failure, start_time}}
        ]
      end

    opts = [strategy: :one_for_all, name: Gvpbonus.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
