defmodule Gvp.PushSum.Driver do
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
    {:ok, {num_of_nodes, topology, []}}
  end

  def handle_info(:kickoff, {node_count, topology, deleted_pids}) do
    1..node_count
    |> Enum.map(fn i -> Gvp.PushSum.NodeSupervisor.add_node(i) end)
    |> Gvp.Topologies.initialise(topology)

    node = Gvp.Topologies.get_first()
    GenServer.cast(node, {:next, 0, 0})
    {:noreply, {node_count, topology, deleted_pids}}
  end

  def handle_cast({:done, pid}, {node_count, topology, deleted_pids}) do
    deleted_pids = deleted_pids ++ [pid]
    # IO.inspect([deleted_pids, node_count])
    next_pids = Gvp.Topologies.get_all_neighbours(pid)
    Enum.each(next_pids, fn next_pid -> GenServer.cast(next_pid, {:next, 0, 0}) end)

    if(node_count <= 1) do
      System.halt(0)
    end

    {:noreply, {node_count - 1, topology, deleted_pids}}
  end
end
