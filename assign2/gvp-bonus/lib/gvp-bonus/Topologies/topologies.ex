defmodule Gvpbonus.Topologies do
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

  def handle_cast({:initialise_topo, list, topology}, _map) do
    {:noreply, Gvpbonus.Topo.get_neighbours(list, topology)}
  end

  def handle_call({:random_neighbour, pid}, _from, map) do
    neighbours = Map.get(map, pid)

    random_pid =
      if(neighbours == []) do
        0
      else
        Enum.random(neighbours)
      end

    {:reply, random_pid, map}
  end

  def handle_call({:neighbours, pid}, _from, map) do
    neighbours = Map.get(map, pid)

    {:reply, neighbours, map}
  end

  def handle_call(:get_first, _from, map) do
    {:reply, List.first(Map.keys(map)), map}
  end
end
