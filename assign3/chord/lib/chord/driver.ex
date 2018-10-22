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
    {:ok, {numNodes, numRequests, 30, start_time}}
  end

  def handle_call(:get_m, _from, {numNodes, numRequests, m, start_time}) do
    {:reply, m, {numNodes, numRequests, m, start_time}}
  end

  def handle_info(:kickoff, {numNodes, numRequests, m, start_time}) do
    set = MapSet.new()
    max = :math.pow(2, m) |> round
    node_set = fill_map(set, numNodes, max)
    node_set = Enum.shuffle(node_set)
    # node_set = [10, 20, 15, 35, 5, 3, 4]
    # numNodes = 7
    IO.inspect(node_set)
    {:ok, first_node} = Enum.fetch(node_set, 0)
    _pid = Chord.NodeSupervisor.add_node(first_node, m)
    _pid2 = Chord.NodeSupervisor.add_node(@max, m)
    {:ok} = Chord.Node.create_chord_ring(first_node, @max)

    Chord.Stabilize.start_stabilize()

    Enum.each(
      1..(numNodes - 1),
      fn x ->
        {:ok, node_id} = Enum.fetch(node_set, x)
        _pid = Chord.NodeSupervisor.add_node(node_id, m)
        {:ok} = Chord.Node.join_new_node(node_id, first_node)
        Process.sleep(25)
      end
    )

    decider(node_set, numNodes, max, numRequests)

    {:noreply, {numNodes, numRequests, m, start_time}}
  end

  defp decider(node_set, numNodes, max, numRequests) do
    list =
      Enum.map(0..(numNodes - 1), fn i ->
        {:ok, node} = Enum.fetch(node_set, i)
        GenServer.call(:"node_#{node}", :get_predecessor)
      end)

    list = list ++ [GenServer.call(:"node_#{@max}", :get_predecessor)]

    diff = node_set -- list
    IO.inspect(Enum.count(diff))

    if(diff == []) do
#      Enum.each(0..(numNodes - 1), fn i ->
#        {:ok, node} = Enum.fetch(node_set, i)
#        IO.inspect(["pred_for_#{node}", GenServer.call(:"node_#{node}", :get_predecessor)])
#        IO.inspect(["succ_for_#{node}", GenServer.call(:"node_#{node}", :get_successor)])
#        IO.inspect(GenServer.call(:"node_#{node}", :get_finger_table))
#      end)

      sum = Enum.reduce(node_set,0, fn node,acc ->
        random_keys = MapSet.new()
        random_keys = fill_map(random_keys, numRequests, max)
        random_keys = Enum.shuffle(random_keys)
#        IO.inspect([node, random_keys])

        sum1 = Enum.reduce(random_keys,0, fn key, acc1 ->
          {succ, hops} = GenServer.call(:"node_#{node}", {:find_successor_lookup, {key, 0}})

          succ =
            if(succ == @max) do
              GenServer.call(:"node_#{@max}", :get_successor)
            else
              succ
            end

#          IO.inspect([succ, hops])
          acc1 + hops
        end)
        acc + sum1
      end)
      IO.inspect sum
      IO.inspect ["avg number of hops = ",sum/(numNodes*numRequests)]
      IO.inspect ["log2(#{numNodes}) = ",:math.log2(numNodes)]
      IO.inspect ["log10(#{numNodes}) = ",:math.log10(numNodes)]
      System.halt(0)
    else
      decider(node_set, numNodes, max, numRequests)
    end
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
