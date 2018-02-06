# Mihail Vanea (mv1315)

defmodule Peer do

  def start() do
    IO.puts(["Peer at ", DNS.my_ip_addr])
    pl = Node.spawn(:'node1@container1.localdomain', PL, :start, [])
    next(pl)
  end

  defp next(pl) do
    {:start, system2} -> 
      send(system2, {:bind, pl})
      next(pl)
  end

end
