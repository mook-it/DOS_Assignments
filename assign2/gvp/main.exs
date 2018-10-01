args = System.argv()
  #IO.puts("in here")
numNodes = String.to_integer(Enum.at(args, 0))
topology = Enum.at(args, 1)
algorithm = Enum.at(args, 2)

Gvp.Application.start(:normal,{numNodes,topology, algorithm})
