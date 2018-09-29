defmodule Gvp.Topologies do
  use GenServer
  def start_link() do
    GenServer.start_link(__MODULE__, {num_of_nodes, topology}, name: @me)
  end
  def init(num_of_nodes, topology, list) do

  end

  def get_neighbour(node_tuple) do
  end

  def update_topology(node_tuple) do
  end
end
