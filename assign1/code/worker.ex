defmodule Worker do
  def work(scheduler) do
    send(scheduler, {:ready, self()})

    receive do
      {:work, i, k, client} ->
        sum = calc(i, k, i)
        m = :math.sqrt(sum)
        comp = m - :math.floor(m)
        send(client, {:answer, i, comp, self()})


        #IO.puts(Node.self())

        work(scheduler)

      {:shutdown} ->
        exit(:normal)
    end
  end

  # very inefficient, deliberately
  defp calc(i, k, j) do
    if(i == j + k - 1) do
      i * i
    else
      i * i + calc(i + 1, k, j)
    end
  end
end
