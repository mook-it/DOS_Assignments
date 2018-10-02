defmodule Gvpbonus.Gossip.Node do
  use GenServer, restart: :transient

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  def init(:no_args) do
    {:ok, 0}
  end

  def handle_cast(:next, count) do
    if(count == 0) do
      # IO.inspect [self(), count]
      [{_, completed}] = :ets.lookup(:failureCheckUp, "completed")
      :ets.insert(:failureCheckUp, {"completed", completed + 1})
      Gvpbonus.Gossip.Driver.done(self())
    end

    if(count <= 9) do
      next_pids = Gvpbonus.Topologies.get_all_neighbours(self())

      [{_, failed}] = :ets.lookup(:failureCheckUp, "failed")

      next_pids_alive = Enum.filter(next_pids, fn x -> !MapSet.member?(failed, x) end)

      Enum.each(next_pids_alive, fn next_pid -> GenServer.cast(next_pid, :next) end)
    end

    {:noreply, count + 1}
  end
end
