# Mihail Vanea (mv1315)

defmodule System2 do

  def main() do
    IO.puts(["System2 at ", DNS.my_ip_addr()])
    peers = [] 
    no_peers = 5
    max_broadcasts = 1000
    timeout = 3000
    peers = for _ <- 1..no_peers, do:
      peers ++ Node.spawn(:'node1@container1.localdomain', Peer, :start, [])
    for p <- peers, do: 
      send p, {:start, self()}
    peer_pl = %{}
    peer_pl = for p <- peers, do:
      Map.put(peer_pl, peer, nil)
    next(peer_pl, no_peers)
  end

  defp next(peer_pl, 0) do
    for p <- Map.keys(peer_pl), do:
      send(p, {:switch, app_pl})
  end

  defp next(peer_pl, app_pl, no_peers) do
    receive do
      {:bind, peer, app, pl} -> 
        peer_pl = Map.update(peer_pl, peer, fn _ -> pl end)
        app_pl = Map.update(app_pl, app, fn _ -> pl end)
        for p <- Map.keys(peer_pl), do:
          send(:bind, peer_pl, app_pl)
        next(peer_pl, app_pl, no_peers - 1)
    end
  end

end
