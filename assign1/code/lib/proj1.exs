defmodule Scheduler do
  def run(n, module, func, args, k) do
    1..n
    |> Enum.map(fn _ -> spawn(module, func, [self()]) end)
    |> schedule_processes(args, k, [])
  end

  defp schedule_processes(processes, args, k, results) do
    receive do
      {:ready, pid} when args != [] ->
        [next | tail] = args
        send(pid, {:work, next, k, self()})
        schedule_processes(processes, tail, k, results)

      {:ready, pid} ->
        send(pid, {:shutdown})

        if length(processes) > 1 do
          schedule_processes(List.delete(processes, pid), args, k, results)
        else
          results
        end

      {:answer, number, comp, pid} ->
        if comp == 0 do
          schedule_processes(List.delete(processes, pid), args, k, [number] ++ results)
        else
          schedule_processes(List.delete(processes, pid), args, k, results)
        end
    end
  end
end

defmodule Worker do
  def work(scheduler) do
    send(scheduler, {:ready, self()})

    receive do
      {:work, i, k, client} ->
        sum = calc(i, k, i)
        m = :math.sqrt(sum)
        comp = m - :math.floor(m)
        send(client, {:answer, i, comp, self()})

        work(scheduler)

      {:shutdown} ->
        exit(:normal)
    end
  end

  defp calc(i, k, j) do
    if(i == j + k - 1) do
      i * i
    else
      i * i + calc(i + 1, k, j)
    end
  end
end

args = System.argv()
n = String.to_integer(Enum.at(args, 0))
to_calculate = Enum.map(1..n, fn x -> x end)
k = String.to_integer(Enum.at(args, 1))

Enum.each(1..20, fn num_processes ->
  {time, result} =
    :timer.tc(
      Scheduler,
      :run,
      [num_processes, Worker, :work, to_calculate, k]
    )

  if num_processes == 1 do
    result = Enum.sort(result)
    IO.puts(inspect(result))
    IO.puts("\n #   time (s)")
  end

  :io.format("~6B     ~.6f~n", [num_processes, time / 1_000_000.0])
end)
