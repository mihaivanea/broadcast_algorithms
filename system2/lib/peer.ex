# Mihail Vanea (mv1315)

defmodule Peer do

  def start() do
    IO.puts(["Peer at ", DNS.my_ip_addr])
    receive do
      {:start, system2} -> 
        pl = Node.spawn(:'node1@container1.localdomain', PL, :start, [])
        app = Node.spawn(:'node1@container1.localdomain', App, :start, [])
        next(system2, pl, app)
    end
  end

  defp next(system2, pl, app) do
    receive do

    end
  end

end
