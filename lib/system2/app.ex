# Mihail Vanea (mv1315)

defmodule App do

  def start() do
    IO.puts(["App at ", DNS.my_ip_addr])
    receive do
      {:bind, neighbours} -> 
        state = %{}
        sent_counts = []
        received_counts = []
        sent_counts = for _ <- neighbours, do: sent_counts ++ 0
        received_counts = for _ <- neighbours, do: received_counts ++ 0
        broadcast_batch = 1
        processing_batch = 5
        state = Map.put(state, :neighbours, neighbours)
        state = Map.put(state, :msgs_left, nil)
        state = Map.put(state, :deadline, :infinity)
        state = Map.put(state, :sent_counts, sent_counts)
        state = Map.put(state, :received_counts, received_counts)
        state = Map.put(state, :broadcast_batch, broadcast_batch)
        state = Map.put(state, :processing_batch, processing_batch)
        next(state)
    end
  end

  defp next(state) do
    receive do
      {:broadcast, msgs_left, timeout} -> 
        state = Map.update!(state, :msgs_left, fn _ -> msgs_left end)
        state = Map.update!(state, :deadline, fn _ -> timeout + clock() end)
        broadcast(state, state[:broadcast_batch])
      {:finished} -> 
        print_state(state)
    end
  end

  defp broadcast(state, 0) do
    process(state, state[:processing_batch])
  end

  defp broadcast(state, n) do
    if clock() < state[:deadline] and state[:msgs_left] > 0 do
      for n <- state[:neighbours], do:
        send(n, {:msg, self()})
      state = Map.update!(state, :msgs_left, fn x -> x - 1 end)
      state = Map.update!(state, :sent_counts, fn _ -> Enum.map(
        state[:sent_counts], fn x -> x + 1 end) end)
      broadcast(state, n - 1)
    else
      send(self(), {:finished})
      next(state)
    end
  end

  defp process(state, 0) do
    broadcast(state, state[:broadcast_batch])
  end

  defp process(state, n) do
    receive do
      {:msg, source} ->
        if clock() < state[:deadline] do
          received_index = 
            Enum.find_index(state[:neighbours], fn x -> x == source end)
          old_val = Enum.at(state[:received_counts], received_index)
          state = Map.update!(state, :received_counts, fn _ -> List.replace_at(
            state[:received_counts], received_index, old_val + 1) end)
          process(state, n - 1)
        else
          send(self(), {:finished})
          next(state)
        end
    end
  end

  defp clock() do
    System.system_time(:milliseconds)
  end

  defp print_state(state) do
    out_index = inspect(Enum.find_index(state[:neighbours], 
      fn x -> x == self() end)) <> ":"
    out_list = merge_lists(state[:sent_counts], state[:received_counts]) 
    out_counts = Enum.map(out_list, fn x -> to_int(x) end)
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

  defp merge_lists([h1], [h2]) do 
    [" {", h1, ",", h2, "}"] 
  end

  defp merge_lists([h1|t1], [h2|t2]) do 
    [" {", h1, ",", h2, "}"] ++ merge_lists(t1, t2) 
  end

end
