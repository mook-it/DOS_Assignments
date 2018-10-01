args = System.argv()
  #IO.puts("in here")
numNodes = String.to_integer(Enum.at(args, 0))
topology = Enum.at(args, 1)
algorithm = Enum.at(args, 2)

{time, _} =
  :timer.tc(
    Gvp.Application,
    :start,
    [:normal,{numNodes,topology, algorithm}]
  )

:io.format("~.6f~n", [time / 1_000_000.0])
