defmodule Chord.Node do
  use GenServer, restart: :transient

  # API
  def start_link(node_id) do
    # IO.inspect node_id
    GenServer.start_link(__MODULE__, :no_args, name: :"node_#{node_id}")
  end

  def create_chord_ring(new_node) do
    GenServer.call(:"node_#{new_node}", {:create, new_node})
  end

  def join_new_node(new_node, existing_node) do
    GenServer.cast(:"node_#{new_node}", {:join, new_node, existing_node})
  end

  # Server
  def init(:no_args) do
    {:ok, {0, 0, %{}}}
  end

  def handle_call({:update_successor, node}, _from, {self_node_id, predecessor, finger_table}) do
    {_,finger_table} = Map.get_and_update(finger_table, 0, fn x -> {x, node} end)
    {:reply, {:ok}, {self_node_id, predecessor, finger_table}}
  end

  def handle_call({:create, new_node}, _from, {self_node_id, predecessor, finger_table}) do
    predecessor = nil
    self_node_id = new_node
    finger_table = Map.put(finger_table, 0, self_node_id)
    {:reply, {:ok}, {self_node_id, predecessor, finger_table}}
  end

  def handle_cast(
        {:join, new_node, existing_node},
        {self_node_id, predecessor, finger_table}
      ) do
    IO.puts("in join")
    predecessor = nil
    self_node_id = new_node
    IO.inspect(self_node_id)

    {succ} = GenServer.call(:"node_#{existing_node}", {:find_successor, self_node_id})

    if(existing_node == succ) do
      IO.puts "inside this"
      GenServer.call(:"node_#{existing_node}", {:update_successor, self_node_id})
      GenServer.cast(:"node_#{existing_node}", {:stabilize})
    end

    IO.inspect([self_node_id, "succ", succ])
    finger_table = Map.put(finger_table, 0, succ)

    GenServer.cast(:"node_#{self_node_id}", {:stabilize})
    {:noreply, {self_node_id, predecessor, finger_table}}
  end

  def handle_call({:find_successor, key}, _from, {self_node_id, predecessor, finger_table}) do
    #IO.puts("in find")
    #IO.inspect(finger_table)

    resulting_node =
      if(key > self_node_id && key <= Map.get(finger_table, 0)) do
        Map.get(finger_table, 0)
      else
        prec_node = closest_preceding_node(key, finger_table, self_node_id)

        if(prec_node == self_node_id) do
          prec_node
        else
          GenServer.call(:"node_#{prec_node}", {:find_successor, key})
        end
      end

    {:reply, {resulting_node}, {self_node_id, predecessor, finger_table}}
  end

  def handle_cast({:stabilize}, {self_node_id, predecessor, finger_table}) do
    IO.puts("in stabilize")
    successor = Map.get(finger_table, 0)

    if(successor == self_node_id) do
    else
      IO.puts(self_node_id)
      {x} = GenServer.call(:"node_#{successor}", {:find_predecessor})
      # IO.inspect([self_node_id, successor])

      successor =
        if(x > self_node_id && x < successor) do
          x
        else
          successor
        end

      IO.inspect([self_node_id, "succ", successor])

      {_,finger_table} = Map.get_and_update(finger_table, 0, fn x -> {x, successor} end)
      GenServer.cast(:"node_#{successor}", {:notify, self_node_id})
    end

    Process.sleep(100)
    GenServer.cast(:"node_#{self_node_id}", {:stabilize})
    {:noreply, {self_node_id, predecessor, finger_table}}
  end

  def handle_cast({:fix_fingers}, {self_node_id, predecessor, finger_table}) do
    # IO.puts("in fix_fingers")
    # m = GenServer.call(Chord.Driver, :get_m)
    {m} = Chord.Driver.get_m()
    # IO.inspect(m)

    Enum.each(1..m, fn x ->
      updated_successor =
        find_successor_self(self_node_id + :math.pow(2, x - 1), finger_table, self_node_id)

      {_,finger_table} = Map.get_and_update(finger_table, x-1, fn x -> {x,updated_successor } end)
    end)

    # IO.inspect(["fingering", finger_table])

    GenServer.cast(:"node_#{self_node_id}", {:fix_fingers})
    {:noreply, {self_node_id, predecessor, finger_table}}
  end

  def handle_call({:find_predecessor}, _from, {self_node_id, predecessor, finger_table}) do
    {:reply, {predecessor}, {self_node_id, predecessor, finger_table}}
  end

  def handle_cast({:notify, possible_predecessor}, {self_node_id, predecessor, finger_table}) do
    #IO.puts("in notify")

    predecessor =
      if(
        predecessor == nil ||
          (possible_predecessor > predecessor && possible_predecessor < self_node_id) ||
          predecessor > self_node_id
      ) do
        possible_predecessor
      else
        predecessor
      end

    #IO.inspect([self_node_id, "poss", possible_predecessor])
    #IO.inspect(predecessor)

    # Map.get_and_update(finger_table, 0, fn x -> {x, possible_predecessor})

    {:noreply, {self_node_id, predecessor, finger_table}}
  end

  defp find_successor_self(key, finger_table, self_node_id) do
    # IO.puts("in find self")

    resulting_node =
      if(key > self_node_id && key <= Map.get(finger_table, 0)) do
        Map.get(finger_table, 0)
      else
        prec_node = closest_preceding_node(key, finger_table, self_node_id)

        if(prec_node == self_node_id) do
          prec_node
        else
          GenServer.call(:"node_#{prec_node}", {:find_successor, key})
        end
      end

    resulting_node
  end

  defp closest_preceding_node(key, finger_table, self_node_id) do
    keys = Map.keys(finger_table)
    size_of_table = Enum.count(keys)
    prec_node = loop(size_of_table, finger_table, key, self_node_id)
  end

  def handle_cast({:print_table}, {self_node_id, predecessor, finger_table}) do
    IO.inspect(finger_table)
    {:noreply, {self_node_id, predecessor, finger_table}}
  end

  defp loop(size_of_table, finger_table, key, self_node_id) do
    if(size_of_table == 0) do
      self_node_id
    else
      table_entry = Map.get(finger_table, size_of_table - 1)

      if(table_entry > self_node_id && table_entry < key) do
        table_entry
      else
        loop(size_of_table - 1, finger_table, key, self_node_id)
      end
    end
  end
end
