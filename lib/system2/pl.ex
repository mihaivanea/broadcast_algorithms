defmodule PL do

  def start() do
    IO.puts(["PL at ", DNS.my_ip_addr])
    app = Node.spawn(:'node1@container1.localdomain', App, :start, [])
    next([])
  end

  defp next(pl_list) do
    {:bind, new_pl_list} -> 
      pl_list = new_pl_list 
      next(new_pl_list)
    {:pl_send, message, to} ->  
  end

end
