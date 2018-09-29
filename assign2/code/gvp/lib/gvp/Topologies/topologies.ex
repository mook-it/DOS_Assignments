defmodule Gvp.Topologies do

  def initalise_topology_module(list) do
    table = :ets.new(:pids_registry, [:set, :protected])
    :ets.insert(table, {"listOfpids", list})
  end

  def get_neighbour(key,alogrithm) do
    {_,list} = :ets.lookup(:pids_registry,"listOfpids")
    get_neighbour_helper(key,list,alogrithm,length(list))
  end


  def get_neighbour_helper(key,list,alogrithm,numNodes) do
    neighboursList = []
    cond do
      alogrithm == "line"  -> neighboursList =  cond do
        key == 1 -> [key+1]
        key == numNodes -> [key-1]
        true -> [key-1,key+1]
      end
    end
    index = :rand.uniform(length(neighboursList))-1
    neighbour_id =  Enum.at(neighboursList,index)
    Enum.at(list,neighbour_id)
  end

  def delete_pid(key) do
    {_,list} = :ets.lookup(:pids_registry,"listOfpids")
    value = Enum.at(list,key)
    :ets.update_element(:pids_registry,"listOfpids",List.delete(list,value))
  end

end
