
  args = System.argv()
    #IO.puts("in here")
    numNodes = String.to_integer(Enum.at(args, 0))
    topology = Enum.at(args, 1)

    #IO.puts(numNodes)
    Gvp.Application.start(:normal,{numNodes,topology})
