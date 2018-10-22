defmodule Chord.Stabilize do
  use GenServer
  @me __MODULE__

  # API
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @me)
  end

  def start_stabilize() do
    GenServer.cast(@me, :stabilize)
  end

  # SERVER
  def init(args) do
    {:ok, 0}
  end

  def handle_cast(:stabilize, state) do
    node_supervisor_id = Process.whereis(NodeSupervisor)
    data = DynamicSupervisor.which_children(node_supervisor_id)

    added_nodes =
      Enum.map(data, fn {_, pid, _, _} ->
        pid
      end)

    Enum.each(added_nodes, fn x ->
      GenServer.call(x, :stabilize)
    end)

    Enum.each(added_nodes, fn x ->
      GenServer.call(x, :fix_fingers)
      Process.sleep(10)
    end)

    GenServer.cast(@me, :stabilize)
    {:noreply, state}
  end
end
