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
  def init({numNodes, numRequests, percentage}) do
    Process.send_after(self(), :kickoff, 0)
    {:ok, {numNodes, numRequests, 20, percentage}}
  end

  def handle_call(:get_m, _from, {numNodes, numRequests, m, percentage}) do
    {:reply, m, {numNodes, numRequests, m, percentage}}
  end

  def handle_info(:kickoff, {numNodes, numRequests, m, percentage}) do
    set = MapSet.new()
    max = :math.pow(2, m) |> round
    node_set = fill_map(set, numNodes, max)
    node_set = Enum.shuffle(node_set)

    :ets.new(:chord, [:set, :public, :named_table])
    :ets.insert(:chord, {"failed_nodes", []})
    :ets.insert(:chord, {"hops_count", 0})
    :ets.insert(:chord, {"req_count", 0})
    hash_list = Enum.reduce(1..(numNodes*numRequests), [], fn _, hash_list ->
      hash_list = hash_list ++ [:crypto.hash(:sha, "i") |> Base.encode16 |> String.downcase]
    end)

    :ets.insert(:chord, {"hash_list", hash_list})

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

    decider(node_set, numNodes, max, numRequests, percentage)

    {:noreply, {numNodes, numRequests, m, percentage}}
  end

  defp decider(node_set, numNodes, max, numRequests, percentage) do
    list =
      Enum.map(0..(numNodes - 1), fn i ->
        {:ok, node} = Enum.fetch(node_set, i)
        GenServer.call(:"node_#{node}", :get_predecessor)
      end)

    list = list ++ [GenServer.call(:"node_#{@max}", :get_predecessor)]

    diff = node_set -- list

    if(diff == []) do
      Enum.each(node_set, fn node ->
        random_keys = MapSet.new()
        random_keys = fill_map(random_keys, numRequests, max)
        random_keys = Enum.shuffle(random_keys)

        Enum.each(random_keys, fn key ->
          [{_, req_count}] = :ets.lookup(:chord, "req_count")
          req_count = req_count + 1
          :ets.insert(:chord, {"req_count", req_count})
          GenServer.cast(:"node_#{node}", {:find_successor_lookup, {key, 0}})
          Process.sleep(1)
        end)
      end)

      decider2(numNodes, numRequests, max, node_set, percentage)
    else
      decider(node_set, numNodes, max, numRequests, percentage)
    end
  end

  defp decider2(numNodes, numRequests, max, node_set, percentage) do
    [{_, req_count}] = :ets.lookup(:chord, "req_count")

    if(req_count == 0) do
      [{_, sum}] = :ets.lookup(:chord, "hops_count")
      IO.inspect(["avg number of hops = ", sum / (numNodes * numRequests)])
      IO.inspect(["log2(#{numNodes}) = ", :math.log2(numNodes)])
      IO.inspect(["log10(#{numNodes}) = ", :math.log10(numNodes)])
      :ets.insert(:chord, {"hops_count", 0})
      node_deletion(percentage, node_set, numNodes, numRequests, max)
    else
      decider2(numNodes, numRequests, max, node_set, percentage)
    end
  end

  defp node_deletion(percentage, node_set, numNodes, numRequests, max) do
    count = percentage / 100 * numNodes
    positions = MapSet.new()
    positions_to_delete = fill_map(positions, count, numNodes-1)

    deleted_nodes =
      Enum.reduce(positions_to_delete, [], fn i, deleted_nodes ->
        {:ok, node} = Enum.fetch(node_set, i)
        GenServer.call(:"node_#{node}", :normal_departure)
        deleted_nodes ++ [node]
      end)

    node_set = node_set -- deleted_nodes

    :ets.insert(:chord, {"failed_nodes", deleted_nodes})
    # Process.sleep(1000)

    Enum.each(node_set, fn node ->
      random_keys = MapSet.new()
      random_keys = fill_map(random_keys, numRequests, max)
      random_keys = Enum.shuffle(random_keys)

      Enum.each(random_keys, fn key ->
        [{_, req_count}] = :ets.lookup(:chord, "req_count")
        req_count = req_count + 1
        :ets.insert(:chord, {"req_count", req_count})
        GenServer.cast(:"node_#{node}", {:find_successor_lookup, {key, 0}})
        Process.sleep(1)
      end)
    end)

    decider3(numNodes, Enum.count(node_set), numRequests)
  end

  defp decider3(numNodes, count, numRequests) do
    [{_, req_count}] = :ets.lookup(:chord, "req_count")

    if(req_count == 0) do
      [{_, sum}] = :ets.lookup(:chord, "hops_count")
      IO.puts "After Failure"
      IO.inspect(["avg number of hops = ", sum / (numNodes * numRequests)])
      IO.inspect(["log2(#{count}) = ", :math.log2(count)])
      IO.inspect(["log10(#{count}) = ", :math.log10(count)])
      System.halt(0)
    else
      decider3(numNodes, count, numRequests)
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
