defmodule Peer do

  def start() do
    IO.puts(["Peer at ", DNS.my_ip_addr])
    receive do
      {:bind, neighbours} -> next(neighbours, 0)
    end
  end

  defp next(neighbours, count) do
    receive do
      {:hello} -> forward(neighbours, count) 
    after 1000 -> 
      IO.puts(["\t\tPeer with #{Kernel.inspect(self())} received #{count} messages"])
    end
  end

  defp forward(neighbours, count) do
    if count == 0 do
      for n <- neighbours, do: send n, {:hello} 
      next(neighbours, count + 1)
    else
      next(neighbours, count + 1)
    end
  end

end
