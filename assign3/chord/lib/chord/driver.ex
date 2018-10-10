defmodule Chord.Driver do
  use GenServer
  @me __MODULE__

  # API
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @me)
  end

  def get_m() do
    GenServer.call(@me, :get_m)
  end

  # SERVER
  def init({numNodes, numRequests, start_time}) do
    Process.send_after(self(), :kickoff, 0)
    {:ok, {numNodes, numRequests, 5, 0, start_time}}
  end

  def handle_call(:get_m, _from, {numNodes, numRequests, m, ring_length, start_time}) do
    # IO.puts("in get_m")
    {:reply, {m}, {numNodes, numRequests, m, ring_length, start_time}}
  end

  def handle_info(:kickoff, {numNodes, numRequests, m, ring_length, start_time}) do
    set = MapSet.new()
    max = :math.pow(2, m) |> round
    node_set = fill_map(set, numNodes, max)
    IO.inspect(node_set)
    {:ok, first_node} = Enum.fetch(node_set, 0)
    pid = Chord.NodeSupervisor.add_node(first_node)
    {:ok} = Chord.Node.create_chord_ring(first_node)
    #GenServer.cast(:"node_#{first_node}", {:stabilize})
    GenServer.cast(:"node_#{first_node}", {:fix_fingers})
    ring_length = ring_length + 1
    # IO.inspect([first_node, pid])

    #GenServer.cast(:"node_#{first_node}", {:print_table})

    Enum.each(
      1..(numNodes - 1),
      fn x ->
        {:ok, node_id} = Enum.fetch(node_set, x)
        pid2 = Chord.NodeSupervisor.add_node(node_id)
        Chord.Node.join_new_node(node_id, first_node)
        GenServer.cast(:"node_#{node_id}", {:fix_fingers})
        ring_length = ring_length + 1
        #IO.inspect(pid2)
        Process.sleep(5000)
        #GenServer.cast(:"node_#{node_id}", {:print_table})
      end
    )

    # {:ok, node_id} = Enum.fetch(node_set, 1)
    # pid2 = Chord.NodeSupervisor.add_node(node_id)
    # Chord.Node.join_new_node(node_id, first_node)
    # # GenServer.cast(:"node_#{node_id}", {:fix_fingers})
    # ring_length = ring_length + 1
    #
    #
    #
    #
    # {:ok, node_id} = Enum.fetch(node_set, 2)
    # pid3 = Chord.NodeSupervisor.add_node(node_id)
    # Chord.Node.join_new_node(node_id, first_node)
    # # GenServer.cast(:"node_#{node_id}", {:fix_fingers})
    # ring_length = ring_length + 1

    Process.sleep(10000)
    GenServer.cast(:"node_#{first_node}", {:print_table})

    # Enum.each(node_set, fn node_id -> GenServer.call(:"node_#{node_id}", {:print_table}) end)

    # System.halt(0)
    {:noreply, {numNodes, numRequests, m, ring_length, start_time}}
  end

  defp fill_map(node_set, numNodes, max) do
    if(MapSet.size(node_set) >= numNodes) do
      node_set
    else
      rand_node_id = Enum.random(1..max)
      node_set = MapSet.put(node_set, rand_node_id)
      fill_map(node_set, numNodes, max)
    end
  end
end
