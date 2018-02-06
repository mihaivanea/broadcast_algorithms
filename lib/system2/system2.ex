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
    next([])
  end

  defp next(pl_list, peers) do
    receive do
      {:bind, pl} -> 
        pl_list = pl_list ++ p
        for p <- pl_list, do:
          send(:bind, pl_list)
        next(pl_list, peers)
    end

  end

end
