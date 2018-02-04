defmodule Peer do

  def start() do
    IO.puts(["Peer at ", DNS.my_ip_addr])
    receive do
      {:bind, neighbours} -> 
        sent_to_counts = []
        received_from_counts = []
        sent_to_counts = for _ <- neighbours, do: sent_to_counts ++ 0
        received_from_counts = for _ <- neighbours, do: received_from_counts ++ 0
        next(neighbours, nil, 3000, sent_to_counts, received_from_counts)
    end
  end

  defp next(neighbours, max_broadcasts, timeout, sent_to_counts, received_from_counts) do
    receive do
      {:broadcast, max_broadcasts, timeout} -> 
        for n <- neighbours, do:
          send(n, {:msg, self()})
        sent_to_counts = Enum.map(sent_to_counts, fn x -> x + 1 end)
        next(neighbours, max_broadcasts - 1, timeout, sent_to_counts, received_from_counts)
      {:msg, source} ->
        received_from_index = 
          Enum.find_index(neighbours, fn x -> x == source end)
        old_val = Enum.at(received_from_counts, received_from_index)
        received_from_counts = 
          List.replace_at(received_from_counts, received_from_index, old_val + 1) 
        next(neighbours, max_broadcasts, timeout, sent_to_counts, received_from_counts)
    after timeout -> 
      print_state(neighbours, sent_to_counts, received_from_counts)
    end
  end

  defp print_state(neighbours, sent_to_counts, received_from_counts) do
    out_index = inspect(Enum.find_index(neighbours, fn x -> x == self() end)) <> ":"
    out_list = merge_lists(sent_to_counts, received_from_counts) 
    out_counts = []
    out_counts = for l <- out_list, do: out_counts = out_counts ++ to_int(l) 
    out_counts = Enum.join(out_counts, "")
    IO.puts(out_index <> out_counts)
  end

  def to_int(x) do
    if is_number(x) do
      Integer.to_charlist(x)
    else
      x
    end
  end

  def merge_lists([h1], [h2]) do [" {", h1, ",", h2, "}"] end
  def merge_lists([h1|t1], [h2|t2]) do [" {", h1, ",", h2, "}"] ++ merge_lists(t1, t2) end

end
