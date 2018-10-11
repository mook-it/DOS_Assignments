defmodule Chord.Driver do
  use GenServer
  @me __MODULE__
  @max 100_000_000_000_000_000_000_000_000

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
    {:ok, {numNodes, numRequests, 12, 0, start_time}}
  end

  def handle_call(:get_m, _from, {numNodes, numRequests, m, ring_length, start_time}) do
    {:reply, {m}, {numNodes, numRequests, m, ring_length, start_time}}
  end

  def handle_info(:kickoff, {numNodes, numRequests, m, ring_length, start_time}) do
    set = MapSet.new()
    max = :math.pow(2, m) |> round
    node_set = fill_map(set, numNodes, max)
    node_set = Enum.shuffle(node_set)
    node_set = [10, 20, 15, 35, 5, 3, 4]
    numNodes = 7
    IO.inspect(node_set)
    {:ok, first_node} = Enum.fetch(node_set, 0)
    _pid = Chord.NodeSupervisor.add_node(first_node)
    _pid2 = Chord.NodeSupervisor.add_node(@max)
    {:ok} = Chord.Node.create_chord_ring(first_node, @max)
    # IO.inspect(GenServer.call(:"node_#{first_node}", :get_predecessor))
    # IO.inspect(GenServer.call(:"node_#{first_node}", :get_successor))
    # IO.inspect(GenServer.call(:"node_#{@max}", :get_predecessor))
    # IO.inspect(GenServer.call(:"node_#{@max}", :get_successor))

    GenServer.cast(:"node_#{first_node}", :stabilize)
    # GenServer.cast(:"node_#{first_node}", :fix_fingers)
    Process.sleep(100)
    GenServer.cast(:"node_#{@max}", :stabilize)
    # GenServer.cast(:"node_#{@me}", :fix_fingers)
    ring_length = ring_length + 1

    Enum.each(
      # (numNodes - 1),
      1..(numNodes - 1),
      fn x ->
        {:ok, node_id} = Enum.fetch(node_set, x)
        IO.puts("adding node_#{node_id}")
        _pid = Chord.NodeSupervisor.add_node(node_id)
        {:ok} = Chord.Node.join_new_node(node_id, first_node)

        Enum.each(0..x, fn i ->
          {:ok, node} = Enum.fetch(node_set, i)
          GenServer.cast(:"node_#{node}", :stabilize)
          IO.inspect(["pred_for_#{node}", GenServer.call(:"node_#{node}", :get_predecessor)])
          # Process.sleep(100)
        end)

        GenServer.cast(:"node_#{@max}", :stabilize)
        IO.inspect(["pred_for_#{@max}", GenServer.call(:"node_#{@max}", :get_predecessor)])

        # GenServer.cast(:"node_#{node_id}", {:fix_fingers})
        ring_length = ring_length + 1
      end
    )

    System.halt(0)

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
