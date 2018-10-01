defmodule Gvp.Gossip.Node do
  use GenServer, restart: :transient

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  def init(:no_args) do
    {:ok, 0}
  end

  def handle_cast(:next, count) do
    # IO.inspect([self(), count])
    if(count <= 9) do
      next_pids = Gvp.Topologies.get_all_neighbours(self())

      Enum.each(next_pids, fn next_pid -> GenServer.cast(next_pid, :next) end)

      if(count == 0) do
        # IO.inspect [self(), count]
        Gvp.Gossip.Driver.done(self())
      end
    end

    {:noreply, count + 1}
  end
end
