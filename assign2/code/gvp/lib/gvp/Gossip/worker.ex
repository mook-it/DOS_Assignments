defmodule Gvp.Gossip.Worker do
  use GenServer, restart: :transient

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  def init(:no_args) do
    Process.send_after(self(), :do_one_file, 0)
    { :ok, %{:msg => "", :times => 0} }
  end

  
end
