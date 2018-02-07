# Mihail Vanea (mv1315)

defmodule System2 do

  def main() do
    IO.puts(["System2 at ", DNS.my_ip_addr()])
    no_peers = 5
    peers = [] 
    peers = for i <- 1..no_peers, do:
      peers ++ Node.spawn(:'node#{i}@container#{i}.localdomain', Peer, :start, [])
    for p <- peers, do: 
      send p, {:start, self()}
    peer_pl = %{}
    app_pl = %{}
    next(peer_pl, app_pl, no_peers)
  end

  defp next(peer_pl, app_pl, 0) do
    for p <- Map.keys(peer_pl), do:
      send(p, {:switch, app_pl})
    start_broadcast(app_pl, length(Map.keys(app_pl)))
  end

  defp next(peer_pl, app_pl, no_peers) do
    receive do
      {:bind, peer, app, pl} -> 
        peer_pl = Map.put(peer_pl, peer, pl)
        app_pl = Map.put(app_pl, app, pl)
        next(peer_pl, app_pl, no_peers - 1)
    end
  end

  defp start_broadcast(app_pl, 0) do
    max_broadcasts = 10000
    timeout = 3000
    for pl <- Map.values(app_pl), do:
      send(pl, {:broadcast, max_broadcasts, timeout})
  end


  defp start_broadcast(app_pl, n) do
    receive do
      {:ready} -> 
        start_broadcast(app_pl, n - 1)
    end
  end

end
