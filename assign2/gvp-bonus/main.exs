
  args = System.argv()
    #IO.puts("in here")
    numNodes = String.to_integer(Enum.at(args, 0))
    topology = Enum.at(args, 1)
  algorithm = Enum.at(args, 2)
    failure = String.to_integer(Enum.at(args, 3))

    #IO.puts(numNodes)
  Gvpbonus.Application.start(:normal,{numNodes,topology,algorithm,failure})
