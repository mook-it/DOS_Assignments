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
    # IO.inspect self()
    # IO.puts "here 1"
    # IO.inspect [diff,changes]
    changes = if(diff < :math.pow(10, -10) && changes == 2) do
      Gvp.PushSum.Driver.done(self())
      IO.inspect(self())
      IO.puts "here 2"
      changes + 1
    else
      changes
    end
    # IO.inspect changes
    changes = if(changes < 3) do
      # IO.puts "here 3"
      # IO.inspect([self(), "here"])
      next_pids = Gvp.Topologies.get_all_neighbours(self())
      # IO.inspect [self(), next_pids]

      Enum.each(next_pids, fn next_pid -> GenServer.cast(next_pid, {:next, s_new, w_new}) end)

      # GenServer.cast(next_pid, {:next, s_new, w_new})

      IO.inspect([self(), new_ratio, diff, changes])
        if(diff < :math.pow(10, -10)) do
          # IO.inspect self()
          changes + 1
        else
          0
        end

    else
      changes
    end
    # IO.inspect changes
    {:noreply, {s_new, w_new, new_ratio, changes}}
  end
end
