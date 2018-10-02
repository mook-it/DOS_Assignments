defmodule Gvp.Topo do
  def get_neighbours(list, topology) do
    neighbours = get_neighbours_helper(list, topology)

    numNodes = length(list)

    Enum.reduce(0..(numNodes - 1), %{}, fn x, acc ->
      Map.put(acc, Enum.at(list, x), Enum.at(neighbours, x))
    end)
  end

  def get_neighbours_helper(list, topology) do
    numNodes = length(list)

    cond do
      topology == "line" ->
        for i <- 0..(numNodes - 1) do
          neighboursList =
            cond do
              i == 0 -> [i + 1]
              i == numNodes - 1 -> [i - 1]
              true -> [i - 1, i + 1]
            end

          [] ++ Enum.map(neighboursList, fn x -> Enum.at(list, x) end)
        end

      topology == "impline" ->
        for i <- 0..(numNodes - 1) do
          neighboursList =
            cond do
              i == 0 -> [i + 1]
              i == numNodes - 1 -> [i - 1]
              true -> [i - 1, i + 1]
            end

          l = [] ++ Enum.map(neighboursList, fn x -> Enum.at(list, x) end)
          l1 = list -- [Enum.at(list, i)]
          l1 = l1 -- l
          l ++ [Enum.random(l1)]
        end

      topology == "full" ->
        for i <- 0..(numNodes - 1) do
          list -- [Enum.at(list, i)]
        end

      topology == "2D" ->
        rowcnt = round(:math.sqrt(numNodes))

        for i <- 1..numNodes do
          neighboursList =
            cond do
              i == 1 -> [i + 1, i + rowcnt]
              i == rowcnt -> [i - 1, i + rowcnt]
              i == numNodes - rowcnt + 1 -> [i + 1, i - rowcnt]
              i == numNodes -> [i - 1, i - rowcnt]
              i < rowcnt -> [i - 1, i + 1, i + rowcnt]
              i > numNodes - rowcnt + 1 and i < numNodes -> [i - 1, i + 1, i - rowcnt]
              rem(i - 1, rowcnt) == 0 -> [i + 1, i - rowcnt, i + rowcnt]
              rem(i, rowcnt) == 0 -> [i - 1, i - rowcnt, i + rowcnt]
              true -> [i - 1, i + 1, i - rowcnt, i + rowcnt]
            end

          [] ++ Enum.map(neighboursList, fn x -> Enum.at(list, x - 1) end)
        end

      topology == "imp2D" ->
        rowcnt = round(:math.sqrt(numNodes))

        for i <- 1..numNodes do
          neighboursList =
            cond do
              i == 1 -> [i + 1, i + rowcnt]
              i == rowcnt -> [i - 1, i + rowcnt]
              i == numNodes - rowcnt + 1 -> [i + 1, i - rowcnt]
              i == numNodes -> [i - 1, i - rowcnt]
              i < rowcnt -> [i - 1, i + 1, i + rowcnt]
              i > numNodes - rowcnt + 1 and i < numNodes -> [i - 1, i + 1, i - rowcnt]
              rem(i - 1, rowcnt) == 0 -> [i + 1, i - rowcnt, i + rowcnt]
              rem(i, rowcnt) == 0 -> [i - 1, i - rowcnt, i + rowcnt]
              true -> [i - 1, i + 1, i - rowcnt, i + rowcnt]
            end

          l = [] ++ Enum.map(neighboursList, fn x -> Enum.at(list, x - 1) end)

          l1 = list -- [Enum.at(list, i - 1)]
          l1 = l1 -- l
          l ++ [Enum.random(l1)]
        end

      topology == "torus" ->
        rowcnt = round(:math.sqrt(numNodes))

        for i <- 1..numNodes do
          neighboursList =
            cond do
              i == 1 ->
                [i + 1, i + rowcnt, i + (rowcnt - 1) * rowcnt, i + rowcnt - 1]

              i == rowcnt ->
                [i - 1, i + rowcnt, i + (rowcnt - 1) * rowcnt, i - rowcnt - 1]

              i == numNodes - rowcnt + 1 ->
                [i + 1, i - rowcnt, i - (rowcnt - 1) * rowcnt, i + rowcnt - 1]

              i == numNodes ->
                [i - 1, i - rowcnt, i - rowcnt - 1, i - (rowcnt - 1) * rowcnt]

              i < rowcnt ->
                [i - 1, i + 1, i + rowcnt, i + (rowcnt - 1) * rowcnt]

              i > numNodes - rowcnt + 1 and i < numNodes ->
                [i - 1, i + 1, i - rowcnt, i - (rowcnt - 1) * rowcnt]

              rem(i - 1, rowcnt) == 0 ->
                [i + 1, i - rowcnt, i + rowcnt, i + rowcnt - 1]

              rem(i, rowcnt) == 0 ->
                [i - 1, i - rowcnt, i + rowcnt, i - rowcnt - 1]

              true ->
                [i - 1, i + 1, i - rowcnt, i + rowcnt]
            end

          [] ++ Enum.map(neighboursList, fn x -> Enum.at(list, x - 1) end)
        end

      topology == "3D" ->
        rowcnt = round(:math.pow(numNodes, 1 / 3))
        colmcnt = rowcnt * rowcnt

        for i <- 1..numNodes do
          neighboursList =
            cond do
              i == 1 ->
                [i + 1, i + rowcnt, i + colmcnt]

              i == rowcnt ->
                [i - 1, i + rowcnt, i + colmcnt]

              i == colmcnt - rowcnt + 1 ->
                [i + 1, i - rowcnt, i + colmcnt]

              i == colmcnt ->
                [i - 1, i - rowcnt, i + colmcnt]

              i == 1 + colmcnt ->
                [i + 1, i - colmcnt, i + rowcnt, i + colmcnt]

              i == rowcnt + colmcnt ->
                [i - 1, i - colmcnt, i + rowcnt, i + colmcnt]

              i == 2 * colmcnt - rowcnt + 1 ->
                [i + 1, i - colmcnt, i - rowcnt, i + colmcnt]

              i == 2 * colmcnt ->
                [i - 1, i - colmcnt, i - rowcnt, i + colmcnt]

              i == 1 + 2 * colmcnt ->
                [i + 1, i + rowcnt, i - colmcnt]

              i == rowcnt + 2 * colmcnt ->
                [i - 1, i + rowcnt, i - colmcnt]

              i == colmcnt + 2 * colmcnt - rowcnt + 1 ->
                [i + 1, i - rowcnt, i - colmcnt]

              i == colmcnt + 2 * colmcnt ->
                [i - 1, i - rowcnt, i - colmcnt]

              i < rowcnt ->
                [i - 1, i + 1, i + rowcnt, i + colmcnt]

              i > colmcnt - rowcnt + 1 and i < colmcnt ->
                [i - 1, i + 1, i - rowcnt, i + colmcnt]

              rem(i - 1, rowcnt) == 0 and i < colmcnt ->
                [i + 1, i - rowcnt, i + rowcnt, i + colmcnt]

              rem(i, rowcnt) == 0 and i < colmcnt ->
                [i - 1, i - rowcnt, i + rowcnt, i - colmcnt]

              i < colmcnt ->
                [i - 1, i + 1, i - rowcnt, i + rowcnt, i + colmcnt]

              i < colmcnt + rowcnt and i > 2 * colmcnt ->
                [i - 1, i + 1, i + colmcnt, i - colmcnt, i + rowcnt]

              i > 2 * colmcnt - rowcnt + 1 and i < 2 * colmcnt ->
                [i - 1, i + 1, i - rowcnt, i + colmcnt, i - colmcnt]

              rem(i - 1, rowcnt) == 0 and i < 2 * colmcnt ->
                [i + 1, i - rowcnt, i + rowcnt, i + colmcnt, i - colmcnt]

              rem(i, rowcnt) == 0 and i < 2 * colmcnt ->
                [i - 1, i - rowcnt, i + rowcnt, i + colmcnt, i - colmcnt]

              i < 2 * colmcnt + rowcnt and i > 2 * colmcnt ->
                [i - 1, i + 1, i + rowcnt, i - colmcnt]

              i > 3 * colmcnt - rowcnt + 1 and i < 3 * colmcnt ->
                [i - 1, i + 1, i - rowcnt, i - colmcnt]

              rem(i - 1, rowcnt) == 0 and i < 3 * colmcnt ->
                [i + 1, i - rowcnt, i + rowcnt, i - colmcnt]

              rem(i, rowcnt) == 0 and i < 3 * colmcnt ->
                [i - 1, i - rowcnt, i + rowcnt, i - colmcnt]

              i < 3 * colmcnt and i > 2 * colmcnt ->
                [i - 1, i + 1, i - rowcnt, i + rowcnt, i - colmcnt]

              true ->
                [i - 1, i + 1, i - rowcnt, i + rowcnt, i + colmcnt, i - colmcnt]
            end

          [] ++ Enum.map(neighboursList, fn x -> Enum.at(list, x - 1) end)
        end

      topology == "rand2D" ->
        m1 = %{}

        m2 =
          Enum.map(list, fn x -> Map.put(m1, x, [:rand.uniform(100)] ++ [:rand.uniform(100)]) end)

        Enum.reduce(m2, [], fn k, l2 ->
          [key1] = Map.keys(k)
          list = Map.values(k)

          l =
            [] ++
              Enum.map(m2, fn x ->
                if connect_component(list, Map.values(x)) do
                  Enum.at(Map.keys(x), 0)
                end
              end)

          l = Enum.filter(l, &(!is_nil(&1)))
          l = l -- [key1]
          l2 ++ [l]
        end)
    end
  end

  def connect_component(l1, l2) do
    l2 = Enum.at(l2, 0)
    l1 = Enum.at(l1, 0)
    x_dist = :math.pow(Enum.at(l2, 0) - Enum.at(l1, 0), 2)
    y_dist = :math.pow(Enum.at(l2, 1) - Enum.at(l1, 1), 2)

    dist = round(:math.sqrt(x_dist + y_dist))

    cond do
      dist <= 10 -> true
      dist > 10 -> false
    end
  end
end
