# Mihail Vanea (mv1315)

defmodule System6 do

  def main() do
    IO.puts(["System6 at ", DNS.my_ip_addr()])
    no_peers = 5
    peers = [] 
    peers = for _ <- 1..no_peers, do:
      peers ++ Node.spawn(:'node1@container1.localdomain', Peer, :start, [])
    for p <- peers, do: 
      send p, {:start, self()}
    peer_pl = %{}
    app_pl = %{}
    faulty_peer = Enum.at(peers, 3)
    next(peer_pl, app_pl, no_peers, faulty_peer)
  end

  defp next(peer_pl, app_pl, 0, faulty_peer) do
    for p <- Map.keys(peer_pl), do:
      send(p, {:switch, app_pl})
    start_broadcast(app_pl, length(Map.keys(app_pl)), faulty_peer)
  end

  defp next(peer_pl, app_pl, no_peers, faulty_peer) do
    receive do
      {:bind, peer, app, pl} -> 
        peer_pl = Map.put(peer_pl, peer, pl)
        app_pl = Map.put(app_pl, app, pl)
        next(peer_pl, app_pl, no_peers - 1, faulty_peer)
    end
  end

  defp start_broadcast(app_pl, 0, faulty_peer) do
    max_broadcasts = 1000
    timeout = 3000
    for pl <- Map.values(app_pl), do:
      send(pl, {:broadcast, max_broadcasts, timeout})
    Process.sleep(5)
    send(faulty_peer, {:kill})
  end


  defp start_broadcast(app_pl, n, faulty_peer) do
    receive do
      {:ready} -> 
        start_broadcast(app_pl, n - 1, faulty_peer)
    end
  end

end
