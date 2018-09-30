defmodule Gvp.Gossip.Node do
  use GenServer, restart: :transient

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  def init(:no_args) do
    {:ok, 0}
  end

  def handle_info(:next, count) do
    if(count <= 9) do
      next_pids = Gvp.Topologies.get_all_neighbours(self())

      # if next_pids == [] do
      #   IO.puts "HEYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
      #   Gvp.Gossip.Driver.done()
      #   # {:stop, :normal, nil}
      # else
      # IO.inspect([self(), count, next_pids])
      Enum.each(next_pids, fn next_pid -> send(next_pid, :next) end)

      if(count == 0) do
        # IO.inspect [self(), count]
        Gvp.Gossip.Driver.done()
      end
    end
    {:noreply, count + 1}
  end
end
