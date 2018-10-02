defmodule Gvp.Application do
  use Application

  def start(_type, {numNodes, topology, algorithm, start_time}) do
    children =
      if algorithm == "gossip" do
        [
          Gvp.Topologies,
          Gvp.Gossip.NodeSupervisor,
          {Gvp.Gossip.Driver, {numNodes, topology, start_time}}
        ]
      else
        [
          Gvp.Topologies,
          Gvp.PushSum.NodeSupervisor,
          {Gvp.PushSum.Driver, {numNodes, topology, start_time}}
        ]
      end

    opts = [strategy: :one_for_all, name: Gvp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
