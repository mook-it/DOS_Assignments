defmodule Gvp.Topologies do

  def initalise_topology_module(list,topology) do
    table = :ets.new(:pids_registry, [:set, :protected])
    :ets.insert(table, {"listOfpids", list})
    :ets.insert(table, {"topology", topology})
  end

  def get_first() do
    {_,list} = :ets.lookup(:pids_registry,"listOfpids")
    Enum.at(list,0)
  end

  def get_neighbour(pid) do
    {_,list} = :ets.lookup(:pids_registry,"listOfpids")
    {_,topology} = :ets.lookup(:pids_registry,"topology")
    key = find_indexes(list, fn(x) -> x == pid end)
    get_neighbour_helper(key,list,topology,length(list))
  end


  def get_neighbour_helper(key,list,topology,numNodes) do
    neighboursList = []
    cond do
      topology == "line"  -> neighboursList =  cond do
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
