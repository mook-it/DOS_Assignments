defmodule Gvp.Gossip.Worker do
  use GenServer, restart: :transient

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  def init(:no_args) do
    { :ok, 0 }
  end

  def handle_info(:next, count) do
    next_pid = topology.get_neighbour(self())
    
  end
end
