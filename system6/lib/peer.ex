# Mihail Vanea (mv1315)

defmodule Peer do

  def start() do
    IO.puts(["Peer at ", DNS.my_ip_addr])
    pl = Node.spawn_link(:'node1@container1.localdomain', LPL, :start, [])
    beb = Node.spawn_link(:'node1@container1.localdomain', BEB, :start, [])
    erb = Node.spawn_link(:'node1@container1.localdomain', ERB, :start, [])
    app = Node.spawn_link(:'node1@container1.localdomain', App, :start, [])
    next(pl, beb, erb, app, nil)
  end

  defp next(pl, beb, erb, app, system6) do
    receive do
      {:start, system6} ->
        send(system6, {:bind, self(), app, pl})
        next(pl, beb, erb, app, system6)
      {:switch, app_pl} -> 
        send(app, {:bind, Map.keys(app_pl), system6, beb, erb})
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
