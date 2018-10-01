defmodule Gvp.PushSum.Node do
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
    new_ratio = s / w

    diff = abs(diff)

    if(diff < :math.pow(10, -10) && changes == 3) do
      Gvp.PushSum.Driver.done(self())
    else
      changes =
        if(diff < :math.pow(10, -10)) do
          changes + 1
        else
          0
        end

      next_pid = Gvp.Topologies.get_random_neighbour(self())
      GenServer.cast(next_pid, {:next, s / 2, w / 2})
      {:noreply, {s / 2, w / 2}}
    end
  end
end
