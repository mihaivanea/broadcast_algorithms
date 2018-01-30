defmodule Peer do

  def start() do
    IO.puts(["Peer at ", DNS.my_ip_addr])
    receive do
      {:bind, neighbours} -> 
        sent_to_counts = %{}
        received_from_counts = %{}
        for n <- neighbours, do:
          Map.put(sent_to_counts, n, 0)
          Map.put(received_from_counts, n, 0)
        next(neighbours, max_broadcast, timeout, sent_to_counts, received_from_counts)
    end
  end

  defp next(neighbours, max_broadcast, timeout, sent_to_counts, received_from_counts) do
    receive do
      {:broadcast, broadcast, timeout} -> 
        for n <- neighbours, do:
          send(n, {:msg, self()}) 
          sent_to_counts = sent_to_counts[n] + 1
        next(neighbours, max_broadcast - 1, timeout, sent_to_counts, received_from_counts)
      {:}
    after timeout -> 
      puts("Peer #{inspect(self())} ")

    end
  end

  defp forward(neighbours, count) do
    if count == 0 do
      for n <- neighbours, do: send n, {:hello} 
      next(neighbours, count + 1)
    else
      next(neighbours, count + 1)
    end
  end

end
