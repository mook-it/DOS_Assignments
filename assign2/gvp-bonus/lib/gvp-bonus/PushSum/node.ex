defmodule Gvpbonus.PushSum.Node do
  use GenServer, restart: :transient

  def start_link(i) do
    GenServer.start_link(__MODULE__, i)
  end

  def init(i) do
    {:ok, {i, 1, i / 1, 0}}
  end

  def handle_cast({:next, from_s, from_w}, {s, w, ratio, changes}) do
    s = s + from_s
    w = w + from_w
    s_new = s / 2
    w_new = w / 2
    new_ratio = s_new / w_new
    diff = new_ratio - ratio
    diff = abs(diff)

    changes =
      if(diff < :math.pow(10, -10) && changes == 2) do
        Gvpbonus.PushSum.Driver.done(self())
        changes
      else
        next_pids = Gvpbonus.Topologies.get_all_neighbours(self())

        [{_, failed}] = :ets.lookup(:failureCheckUp, "failed")

        next_pids_alive = Enum.filter(next_pids, fn x -> !MapSet.member?(failed, x) end)

        next_pid =
          if(next_pids_alive == []) do
            0
          else
            Enum.random(next_pids_alive)
          end

        if(next_pid != 0) do
          GenServer.cast(next_pid, {:next, s_new, w_new})
        else
          Gvpbonus.PushSum.Driver.done(self())
        end

        if(diff < :math.pow(10, -10)) do
          changes + 1
        else
          0
        end
      end

    {:noreply, {s_new, w_new, new_ratio, changes}}
  end
end
