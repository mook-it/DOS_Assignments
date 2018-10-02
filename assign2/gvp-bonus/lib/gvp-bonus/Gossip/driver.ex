defmodule Gvpbonus.Gossip.Driver do
  use GenServer
  @me __MODULE__

  # API
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @me)
  end

  def done(pid) do
    GenServer.cast(@me, {:done, pid})
  end

  def over() do
    GenServer.cast(@me, :nothing_else_to_do)
  end

  # SERVER
  def init({num_of_nodes, topology, failure, start_time}) do
    Process.send_after(self(), {:kickoff, failure}, 0)
    {:ok, {num_of_nodes, topology, [], start_time}}
  end

  def getConnectComponentCount(pid) do
    [{_, visited}] = :ets.lookup(:failureCheckUp, "visited")
    :ets.insert(:failureCheckUp, {"visited", MapSet.put(visited, pid)})

    neighbours = Gvpbonus.Topologies.get_all_neighbours(pid)
    [{_, visited}] = :ets.lookup(:failureCheckUp, "visited")
    [{_, failed}] = :ets.lookup(:failureCheckUp, "failed")

    alive_pids =
      if(neighbours != nil) do
        Enum.filter(neighbours, fn x -> !MapSet.member?(failed, x) end)
      else
        []
      end

    not_visited_pids = Enum.filter(alive_pids, fn x -> !MapSet.member?(visited, x) end)
    Enum.each(not_visited_pids, fn x -> getConnectComponentCount(x) end)
  end

  def handle_info({:kickoff, failure}, {node_count, topology, deleted_pids, start_time}) do
    listofpids =
      1..node_count
      |> Enum.map(fn _ -> Gvpbonus.Gossip.NodeSupervisor.add_node() end)

    Gvpbonus.Topologies.initialise(listofpids, topology)

    node = Gvpbonus.Topologies.get_first()

    listofpids = listofpids -- [node]

    :ets.new(:failureCheckUp, [:set, :public, :named_table])
    :ets.insert(:failureCheckUp, {"failed", MapSet.new([])})
    :ets.insert(:failureCheckUp, {"completed", 0})
    :ets.insert(:failureCheckUp, {"forcekill", false})
    :ets.insert(:failureCheckUp, {"visited", MapSet.new([])})

    failureNode = trunc(failure * node_count * 0.01)

    Enum.each(Enum.take_random(listofpids, failureNode), fn x ->
      [{_, failed}] = :ets.lookup(:failureCheckUp, "failed")
      :ets.insert(:failureCheckUp, {"failed", MapSet.put(failed, x)})
    end)

    getConnectComponentCount(node)

    [{_, visited}] = :ets.lookup(:failureCheckUp, "visited")
    node_count = MapSet.size(visited)

    GenServer.cast(node, :next)
    {:noreply, {node_count, topology, deleted_pids, start_time}}
  end

  def handle_cast({:done, pid}, {node_count, topology, deleted_pids, start_time}) do
    deleted_pids = deleted_pids ++ [pid]
    [{_, forcekill}] = :ets.lookup(:failureCheckUp, "forcekill")

    if(node_count <= 1 || forcekill) do
      [{_, completed}] = :ets.lookup(:failureCheckUp, "completed")
      IO.puts("How many nodes got the rumor in this failure prone topology:")
      IO.puts(completed)
      end_time = System.monotonic_time(:millisecond)
      time_taken = end_time - start_time
      IO.puts("")
      IO.puts("Time taken:")
      IO.inspect(time_taken)
      System.halt(0)
    end

    {:noreply, {node_count - 1, topology, deleted_pids, start_time}}
  end

  def handle_cast(:nothing_else_to_do, {node_count, topology, deleted_pids, start_time}) do
    [{_, completed}] = :ets.lookup(:failureCheckUp, "completed")
    IO.puts(completed)
    System.halt(0)

    {:noreply, {node_count, topology, deleted_pids, start_time}}
  end
end
