# Mihail Vanea (mv1315)

defmodule Peer do

  def start() do
    IO.puts(["Peer at ", DNS.my_ip_addr])
    pl = Node.spawn(:'node1@container1.localdomain', PL, :start, [])
    app = Node.spawn(:'node1@container1.localdomain', App, :start, [])
    next(pl, app, nil)
  end

  defp next(pl, app, system2) do
    receive do
      {:start, system2} ->
        send(system2, {:bind, self(), app, pl})
        next(pl, app, system2)
      {:switch, app_pl} -> 
        send(app, {:bind, Map.keys(app_pl), system2})
        send(app, {:switch, app_pl})
        send(pl, {:switch, app_pl, app})
    end
  end

end
