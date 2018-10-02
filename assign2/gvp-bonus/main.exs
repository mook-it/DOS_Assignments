args = System.argv()
numNodes = String.to_integer(Enum.at(args, 0))
topology = Enum.at(args, 1)
algorithm = Enum.at(args, 2)
failure = String.to_integer(Enum.at(args, 3))

start_time = System.monotonic_time(:millisecond)
Gvpbonus.Application.start(:normal,{numNodes,topology,algorithm,failure, start_time})
