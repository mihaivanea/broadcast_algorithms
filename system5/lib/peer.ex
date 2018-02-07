# Mihail Vanea (mv1315)

defmodule Peer do

  def start() do
    IO.puts(["Peer at ", DNS.my_ip_addr])
    pl = Node.spawn_link(:'node1@container1.localdomain', LPL, :start, [])
    beb = Node.spawn_link(:'node1@container1.localdomain', BEB, :start, [])
    app = Node.spawn_link(:'node1@container1.localdomain', App, :start, [])
    next(pl, beb, app, nil)
  end

  defp next(pl, beb, app, system5) do
    receive do
      {:start, system5} ->
        send(system5, {:bind, self(), app, pl})
        next(pl, beb, app, system5)
      {:switch, app_pl} -> 
        send(app, {:bind, Map.keys(app_pl), system5, beb})
        send(app, {:switch, app_pl})
        send(pl, {:switch, app_pl, app, beb})
        kill()
    end
  end

  defp kill() do
    receive do
      {:kill} -> Process.exit(self(), :kill)
    end
  end

end
