# Mihail Vanea (mv1315)

defmodule BEB do

  def start() do
    receive do
      {:bind, pl, erb, neighbours} -> 
        next(pl, erb, neighbours)
    end
  end

  defp next(pl, erb, neighbours) do
    receive do
      {:rb_broadcast, message, from} -> 
        for n <- neighbours, do:
          send(pl, {:beb_broadcast, n, message, from})
      {:beb_broadcast, message, source} ->
        send(erb, {:beb_deliver, message, source})
    end
    next(pl, erb, neighbours)
  end
end
