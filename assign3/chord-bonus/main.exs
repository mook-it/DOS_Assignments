args = System.argv()
numNodes = String.to_integer(Enum.at(args, 0))
numRequests = String.to_integer(Enum.at(args, 1))
percentage = String.to_integer(Enum.at(args, 2))

Chord.Application.start(:normal,{numNodes,numRequests, percentage})
