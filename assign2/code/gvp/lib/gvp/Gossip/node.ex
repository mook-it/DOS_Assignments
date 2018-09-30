defmodule Gvp.Gossip.Node do
  use GenServer, restart: :transient

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  def init(:no_args) do
    {:ok, 0}
  end

  def handle_info(:next, count) do
    if(count == 10) do
      Gvp.Gossip.Driver.done()
      {:stop, :normal, nil}
    end
    next_pid = Gvp.Topologies.get_random_neighbour(self())
    IO.inspect [self(), count, next_pid]
    # IO.inspect(next_pid)
    send(next_pid, :next)
    {:noreply, count + 1}
  end
end
