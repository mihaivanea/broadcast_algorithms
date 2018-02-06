# Mihail Vanea (mv1315)

defmodule Peer do

  def start() do
    IO.puts(["Peer at ", DNS.my_ip_addr])
    pl = Node.spawn(:'node1@container1.localdomain', PL, :start, [])
    app = Node.spawn(:'node1@container1.localdomain', App, :start, [])
    next(nil, nil, pl, app)
  end

  defp next(peer_pl, new_app_pl, pl, app) do
    receive do
      {:start, system2} ->
        send(system2, {:bind, self(), app, pl})
        next(nil, nil, pl, app)
      {:bind, new_peer_pl, new_app_pl} -> 
        send(pl, {:bind, new_peer_pl, new_app_pl})
        next(new_peer_pl, new_app_pl, pl, app)
      {:switch, app_pl} -> 
        send(app, {:switch, app_pl})
        send(pl, {:switch, app_pl})
    end
  end

end
