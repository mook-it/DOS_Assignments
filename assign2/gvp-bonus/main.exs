
  args = System.argv()
    #IO.puts("in here")
    numNodes = String.to_integer(Enum.at(args, 0))
    topology = Enum.at(args, 1)
    failure = String.to_integer(Enum.at(args, 2))

    #IO.puts(numNodes)
  Gvpbonus.Application.start(:normal,{numNodes,topology,failure})
