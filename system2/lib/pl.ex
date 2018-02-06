defmodule PL do

  def start() do
    IO.puts(["PL at ", DNS.my_ip_addr])
    next([])
  end

  defp next(pl_list) do
    receive do
      {:bind, new_pl_list} -> 
        pl_list = new_pl_list 
        next(new_pl_list)
        #{:pl_send, message, to} ->  
    end
  end

end
