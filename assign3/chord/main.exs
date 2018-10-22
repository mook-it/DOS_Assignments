args = System.argv()
numNodes = String.to_integer(Enum.at(args, 0))
numRequest = String.to_integer(Enum.at(args, 1))

#start_time = System.monotonic_time(:millisecond)
Chord.Application.start(:normal,{numNodes,numRequest})
