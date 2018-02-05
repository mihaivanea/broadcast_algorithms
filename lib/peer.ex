defmodule Peer do

  def start() do
    IO.puts(["Peer at ", DNS.my_ip_addr])
    receive do
      {:bind, neighbours} -> 
        sent_to_counts = []
        received_counts = []
        sent_to_counts = for _ <- neighbours, do: sent_to_counts ++ 0
        received_counts = for _ <- neighbours, do: received_counts ++ 0
        next(neighbours, nil, nil, sent_to_counts, received_counts)
    end
  end

  defp next(neighbours, max_broadcasts, timeout, sent_to_counts, received_counts) do
    receive do
      {:broadcast, max_broadcasts, timeout} -> 
        #IO.puts("BROADCAST")
        broadcast(neighbours, max_broadcasts, timeout, sent_to_counts, received_counts, 1) 
      {:msg, source} ->
        #IO.puts("RECEIVE")
        received_index = 
          Enum.find_index(neighbours, fn x -> x == source end)
        old_val = Enum.at(received_counts, received_index)
        received_counts = 
          List.replace_at(received_counts, received_index, old_val + 1) 
        next(neighbours, max_broadcasts, timeout, sent_to_counts, received_counts)
    after timeout -> 
      print_state(neighbours, sent_to_counts, received_counts)
    end
  end

  def broadcast(neighbours, max_broadcasts, timeout, sent_to_counts, received_counts, no_msgs) do
    if no_msgs == 0 do
      next(neighbours, max_broadcasts - no_msgs, timeout, sent_to_counts, received_counts)
    else
      for n <- neighbours, do:
        send(n, {:msg, self()})
      sent_to_counts = Enum.map(sent_to_counts, fn x -> x + 1 end)
      broadcast(neighbours, max_broadcasts, timeout, sent_to_counts, received_counts, no_msgs - 1)
    end
  end

  defp print_state(neighbours, sent_to_counts, received_counts) do
    out_index = inspect(Enum.find_index(neighbours, fn x -> x == self() end)) <> ":"
    out_list = merge_lists(sent_to_counts, received_counts) 
    out_counts = []
    out_counts = for l <- out_list, do: out_counts = out_counts ++ to_int(l) 
    out_counts = Enum.join(out_counts, "")
    IO.puts(out_index <> out_counts)
  end

  defp to_int(x) do
    if is_number(x) do
      Integer.to_charlist(x)
    else
      x
    end
  end

  defp merge_lists([h1], [h2]) do [" {", h1, ",", h2, "}"] end
  defp merge_lists([h1|t1], [h2|t2]) do [" {", h1, ",", h2, "}"] ++ merge_lists(t1, t2) end

end
