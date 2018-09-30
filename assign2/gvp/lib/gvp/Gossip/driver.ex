defmodule Gvp.Gossip.Driver do
  use GenServer
  @me __MODULE__

  # API
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @me)
  end

  def done(pid) do
    GenServer.cast(@me, {:done, pid})
  end

  # SERVER
  def init({num_of_nodes, topology}) do
    Process.send_after(self(), :kickoff, 0)
    {:ok, {num_of_nodes,topology, []}}
  end

  def handle_info(:kickoff, {node_count,topology, deleted_pids}) do
    1..node_count
    |> Enum.map(fn _ -> Gvp.Gossip.NodeSupervisor.add_node() end)
    |> Gvp.Topologies.initialise(topology)
    
    node = Gvp.Topologies.get_first()
    GenServer.cast(node, :next)
    {:noreply, {node_count,topology, deleted_pids}}
  end


  def handle_cast({:done,pid}, {node_count, topology, deleted_pids}) do
    deleted_pids = deleted_pids ++ [pid]
    IO.inspect deleted_pids
    if(node_count <= 1) do
      System.halt(0)
    end
    {:noreply, {node_count - 1, topology, deleted_pids}}
  end
end
