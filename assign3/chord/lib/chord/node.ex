defmodule Chord.Node do
  use GenServer, restart: :transient

  # API
  def start_link(node_id) do
    # IO.inspect node_id
    GenServer.start_link(__MODULE__, :no_args, name: :"node_#{node_id}")
  end

  def create_chord_ring(new_node, fake_node) do
    GenServer.call(:"node_#{new_node}", {:create, new_node, fake_node})
  end

  def join_new_node(new_node, existing_node) do
    GenServer.call(:"node_#{new_node}", {:join, new_node, existing_node})
  end

  # Server
  def init(:no_args) do
    {:ok, {0, 0, %{}}}
  end

  def handle_call(:get_predecessor, _from, {self_node_id, predecessor, finger_table}) do
    {:reply, predecessor, {self_node_id, predecessor, finger_table}}
  end

  def handle_call(:get_successor, _from, {self_node_id, predecessor, finger_table}) do
    {:reply, Map.get(finger_table, 0), {self_node_id, predecessor, finger_table}}
  end

  def handle_call(
        {:create_fake, first_node, fake_node},
        _from,
        {self_node_id, predecessor, finger_table}
      ) do
    predecessor = first_node
    self_node_id = fake_node
    finger_table = Map.put(finger_table, 0, first_node)
    {:reply, {:ok}, {self_node_id, predecessor, finger_table}}
  end

  def handle_call(
        {:create, first_node, fake_node},
        _from,
        {self_node_id, predecessor, finger_table}
      ) do
    predecessor = fake_node
    self_node_id = first_node
    finger_table = Map.put(finger_table, 0, fake_node)
    {:ok} = GenServer.call(:"node_#{fake_node}", {:create_fake, first_node, fake_node})
    {:reply, {:ok}, {self_node_id, predecessor, finger_table}}
  end

  def handle_call(
        {:notify, possible_predecessor},
        _from,
        {self_node_id, predecessor, finger_table}
      ) do
    IO.inspect([predecessor, possible_predecessor, self_node_id])

    predecessor =
      if(
        predecessor == nil ||
          (possible_predecessor > predecessor && possible_predecessor < self_node_id) ||
          (predecessor > self_node_id && possible_predecessor < predecessor)
      ) do
        IO.inspect(possible_predecessor)
        possible_predecessor
      else
        IO.puts("hey")
        predecessor
      end

    {:reply, {:ok}, {self_node_id, predecessor, finger_table}}
  end

  def handle_cast(:stabilize, {self_node_id, predecessor, finger_table}) do
    successor = Map.get(finger_table, 0)
    x = GenServer.call(:"node_#{successor}", :get_predecessor)
    # IO.inspect(["in_stab", x, self_node_id])
    # IO.puts "here"

    if(self_node_id == 100_000_000_000_000_000_000_000_000) do
      IO.inspect(["lawda", self_node_id, x, successor])
    end

    if(x != self_node_id) do
      successor =
        if((x > self_node_id && x < successor) || (self_node_id > successor && x < successor)) do
          x
        else
          IO.inspect(["in else", x, self_node_id, successor])
          successor
        end

      {:ok} = GenServer.call(:"node_#{successor}", {:notify, self_node_id})
      {_, finger_table} = Map.get_and_update(finger_table, 0, fn x -> {x, successor} end)
      IO.inspect([self_node_id, finger_table])
      {:noreply, {self_node_id, predecessor, finger_table}}
    else
      IO.inspect([self_node_id, finger_table])
      {:noreply, {self_node_id, predecessor, finger_table}}
    end
  end

  def handle_call(
        {:join, new_node, existing_node},
        _from,
        {self_node_id, predecessor, finger_table}
      ) do
    self_node_id = new_node
    successor = GenServer.call(:"node_#{existing_node}", {:find_successor, self_node_id})
    IO.puts("join")
    IO.inspect([self_node_id, successor])
    finger_table = Map.put_new(finger_table, 0, successor)
    predecessor = nil
    {:ok} = GenServer.call(:"node_#{successor}", {:notify, self_node_id})
    IO.inspect(GenServer.call(:"node_#{successor}", :get_predecessor))
    {:reply, {:ok}, {self_node_id, predecessor, finger_table}}
  end

  defp closest_preceding_node(key, finger_table, self_node_id) do
    keys = Map.keys(finger_table)
    size_of_table = Enum.count(keys)
    prec_node = closest_preceding_node_helper(size_of_table, finger_table, key, self_node_id)
  end

  defp closest_preceding_node_helper(size_of_table, finger_table, key, self_node_id) do
    if(size_of_table == 0) do
      Map.get(finger_table, 0)
    else
      table_entry = Map.get(finger_table, size_of_table - 1)

      if(table_entry > self_node_id && table_entry < key) do
        table_entry
      else
        closest_preceding_node_helper(size_of_table - 1, finger_table, key, self_node_id)
      end
    end
  end

  def handle_call({:find_successor, key}, _from, {self_node_id, predecessor, finger_table}) do
    successor = Map.get(finger_table, 0)

    successor_for_key =
      if(
        (key > self_node_id && key <= successor) || (self_node_id > successor && key < successor)
      ) do
        successor
      else
        n_dash = closest_preceding_node(key, finger_table, self_node_id)
        GenServer.call(:"node_#{n_dash}", {:find_successor, key})
      end

    {:reply, successor_for_key, {self_node_id, predecessor, finger_table}}
  end

  # def handle_cast({:fix_fingers}, {self_node_id, predecessor, finger_table}) do
  #   # IO.puts("in fix_fingers")
  #   # m = GenServer.call(Chord.Driver, :get_m)
  #   {m} = Chord.Driver.get_m()
  #   # IO.inspect(m)
  #
  #   Enum.each(1..m, fn x ->
  #     updated_successor =
  #       find_successor_self(self_node_id + :math.pow(2, x - 1), finger_table, self_node_id)
  #
  #     {_, finger_table} =
  #       Map.get_and_update(finger_table, x - 1, fn x -> {x, updated_successor} end)
  #   end)
  #
  #   # IO.inspect(["fingering", finger_table])
  #
  #   GenServer.cast(:"node_#{self_node_id}", {:fix_fingers})
  #   {:noreply, {self_node_id, predecessor, finger_table}}
  # end

  def handle_cast({:print_table}, {self_node_id, predecessor, finger_table}) do
    IO.inspect(finger_table)
    {:noreply, {self_node_id, predecessor, finger_table}}
  end
end
