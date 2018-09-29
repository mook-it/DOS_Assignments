defmodule Gvp.Gossip.Driver do
  use GenServer
  @me __MODULE__

  # API
  def start_link(_) do
    GenServer.start_link(__MODULE__, {num_of_nodes, topology}, name: @me)
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
    |> Enum.each(fn _ -> Gossip.NodeSupervisor.add_worker() end)
    # topology.init(num_of_nodes, topology, list)
    # node = topology.get_first_node()
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
