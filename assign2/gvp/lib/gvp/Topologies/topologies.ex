defmodule Gvp.Topologies do
  use GenServer
  @me __MODULE__

  # API
  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args, name: @me)
  end

  def initialise(list, topology) do
    GenServer.cast(@me, {:initialise_topo, list, topology})
  end

  def get_all_neighbours(pid) do
    GenServer.call(@me, {:neighbours, pid})
  end

  def get_random_neighbour(pid) do
    GenServer.call(@me, {:random_neighbour, pid})
  end

  def get_first() do
    GenServer.call(@me, :get_first)
  end

  # def update(pid, node_count)  do
  #   GenServer.call(@me, {:update, pid, node_count})
  # end

  # SERVER
  def init(:no_args) do
    {:ok, %{}}
  end

  def handle_cast({:initialise_topo, list, topology}, map) do
    map = Gvp.Topo.get_neighbours(list, topology)
    IO.inspect map
    {:noreply, map}
  end

  def handle_call({:random_neighbour, pid}, _from, map) do
    neighbours = Map.get(map, pid)

    random_pid = Enum.random(neighbours)

    {:reply, random_pid, map}
  end

  def handle_call({:neighbours, pid}, _from, map) do
    neighbours = Map.get(map, pid)

    {:reply, neighbours, map}
  end

  def handle_call(:get_first, _from, map) do
    {:reply, List.first(Map.keys(map)), map}
  end

  # def handle_call({:update, pid, node_count}, _from, map) do
  #   {:reply, node_count-1,remove(map, pid)}
  # end
  #
  # defp remove(map, pid) do
  #   map = Map.delete(map, pid)
  #
  #   new_lists =
  #     Enum.map(map, fn entry ->
  #       {key, list} = entry
  #       List.delete(list, pid)
  #     end)
  #
  #   pids = Map.keys(map)
  #   i = length(pids)
  #
  #   map =
  #     Enum.reduce(0..(i - 1), %{}, fn x, acc ->
  #       Map.put(acc, Enum.at(pids, x), Enum.at(new_lists, x))
  #     end)
  #
  #   IO.puts("item deleted:")
  #   IO.inspect(pid)
  #   map
  # end
end
