defmodule System1 do

  def main() do
    IO.puts(["System1 at ", DNS.my_ip_addr()])
    peers = [] 
    no_peers = 5
    max_broadcasts = 1000
    timeout = 3000
    peers = for _ <- 1..no_peers, do:
      peers ++ Node.spawn(:'node1@container1.localdomain', Peer, :start, [])
    for p <- peers, do: 
      send p, {:bind, peers}
    # send Enum.at(peers, 0), {:hello}
    for p <- peers, do:
      send(p, {:broadcast, max_broadcasts, timeout})
  end

end
