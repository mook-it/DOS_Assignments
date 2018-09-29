defmodule Gvp.Gossip.Node do
  use GenServer, restart: :transient
  import Gvp.Topologies

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  def init(:no_args) do
    {:ok, 0}
  end

  def handle_info(:next, count) do
    next_pid = get_random_neighbour(self())
    send(next_pid, :next)
    {:noreply, count + 1}
  end
end
