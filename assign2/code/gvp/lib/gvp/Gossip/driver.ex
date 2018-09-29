defmodule Gvp.Gossip.Driver do
  use GenServer
  @me __MODULE__

  # API
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @me)
  end

  def done() do
    GenServer.call(@me, :done)
  end

  def get_num_of_nodes() do
    GenServer.call(@me, :get_num_of_nodes)
  end

  # SERVER
  def init({num_of_nodes, topology}) do
    Process.send_after(self(), :kickoff, 0)
    {:ok, num_of_nodes}
  end

  def handle_info(:kickoff, node_count) do
    1..node_count
    |> Enum.map(fn _ -> Gvp.Gossip.NodeSupervisor.add_node() end)
    |> Gvp.Topologies.initialise("line")

    node = Gvp.Topologies.get_first()
    IO.inspect(node)
    # send(node, :next)
    {:noreply, node_count}
  end

  def handle_call(:done, _from, node_count) do
    # REMOVE _FROM via topology
    # topology.update(_from)
    {:noreply, node_count - 1}
  end

  def handle_call(:get_num_of_nodes, _from, node_count) do
    {
      :reply,
      node_count,
      node_count
    }
  end
end
