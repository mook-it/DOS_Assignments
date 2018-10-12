defmodule Chord.FixFingers do
  use GenServer
  @me __MODULE__

  # API
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @me)
  end

  def start_fix_fingers() do
    GenServer.cast(@me, :fix_fingers)
  end

  # SERVER
  def init(args) do
    {:ok, 0}
  end

  def handle_cast(:fix_fingers, state) do
    node_supervisor_id = Process.whereis(NodeSupervisor)
    data = DynamicSupervisor.which_children(node_supervisor_id)

    added_nodes =
      Enum.map(data, fn {_, pid, _, _} ->
        pid
      end)

    Enum.each(added_nodes, fn x ->
      nil
      # GenServer.call(x, :fix_fingers)
    end)

    GenServer.cast(@me, :fix_fingers)
    {:noreply, state}
  end
end
