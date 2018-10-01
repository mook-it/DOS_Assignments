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
    s_new = s / 2
    w_new = w / 2
    new_ratio = s_new / w_new
    diff = new_ratio - ratio
    diff = abs(diff)

    changes =
      if(diff < :math.pow(10, -10) && changes == 2) do
        Gvp.PushSum.Driver.done(self())
        # IO.puts("here")
        changes
      else
        next_pid = Gvp.Topologies.get_random_neighbour(self())
        GenServer.cast(next_pid, {:next, s_new, w_new})

        if(diff < :math.pow(10, -10)) do
          changes + 1
        else
          0
        end
      end

    # IO.inspect changes
    {:noreply, {s_new, w_new, new_ratio, changes}}
  end
end
