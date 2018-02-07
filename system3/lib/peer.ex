# Mihail Vanea (mv1315)

defmodule Peer do

  def start() do
    IO.puts(["Peer at ", DNS.my_ip_addr])
    pl = Node.spawn(:'node1@container1.localdomain', PL, :start, [])
    beb = Node.spawn(:'node1@container1.localdomain', BEB, :start, [])
    app = Node.spawn(:'node1@container1.localdomain', App, :start, [])
    next(pl, beb, app, nil)
  end

  defp next(pl, beb, app, system3) do
    receive do
      {:start, system3} ->
        send(system3, {:bind, self(), app, pl})
        next(pl, beb, app, system3)
      {:switch, app_pl} -> 
        send(app, {:bind, Map.keys(app_pl), system3, beb})
        send(app, {:switch, app_pl})
        send(pl, {:switch, app_pl, app, beb})
    end
  end

end
