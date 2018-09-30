defmodule Gvp.Gossip.Driver do
  use GenServer
  @me __MODULE__

  # API
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @me)
  end

  def done() do
    GenServer.cast(@me, :done)
  end

  # SERVER
  def init({num_of_nodes, topology}) do
    Process.send_after(self(), :kickoff, 0)
    {:ok, {num_of_nodes,topology}}
  end

  def handle_info(:kickoff, {node_count,topology}) do
    1..node_count
    |> Enum.map(fn _ -> Gvp.Gossip.NodeSupervisor.add_node() end)
    |> Gvp.Topologies.initialise(topology)

    node = Gvp.Topologies.get_first()
    send(node, :next)
    {:noreply, {node_count,topology}}
  end
  #
  # def handle_cast(:done, {_node_count = 1,_topology}) do
  #   # IO.puts "HIIIIIIIIIIIIIIIIIIIIIIIIIIIII"
  #   System.halt(0)
  # end

  def handle_cast(:done, {node_count, topology}) do
    IO.puts node_count
    if(node_count <= 1) do
      System.halt(0)
    end

    # new_state = Gvp.Topologies.update(from, node_count)
    # new_state = node_count - 1
    {:noreply, {node_count - 1, topology}}
  end
end
