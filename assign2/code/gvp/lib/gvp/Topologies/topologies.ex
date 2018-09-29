defmodule Gvp.Topologies do



  def get_neighbours(list,topology) do

    numNodes = length(list)

    map = %{}

    cond do
      topology == "line"  -> for i <- 0..numNodes-1 do
                               neighboursList =  cond do
                                 i == 0 -> [i+1]
                                 i == numNodes-1 -> [i-1]
                                 true -> [i-1,i+1]
                               end
                               l = [] ++ Enum.map(neighboursList, fn(x) ->  Enum.at(list,x)
                               end)
                               Map.put(map,Enum.at(list,i),l)

                             end
    end

  end


end
