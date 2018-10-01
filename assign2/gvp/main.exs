
  args = System.argv()
    #IO.puts("in here")
    numNodes = String.to_integer(Enum.at(args, 0))
    topology = Enum.at(args, 1)

    #IO.puts(numNodes)
    #Gvp.Application.start(:normal,{numNodes,topology})

  {time, _} =
    :timer.tc(
      Gvp.Application,
      :start,
      [:normal,{numNodes,topology}]
    )

  :io.format("~.6f~n", [time / 1_000_000.0])
