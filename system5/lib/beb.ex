# Mihail Vanea (mv1315)

defmodule BEB do

  def start() do
    receive do
      {:bind, pl, app, neighbours} -> next(pl, app, neighbours)
    end
  end

  defp next(pl, app, neighbours) do
    receive do
      {:broadcast, message, from} -> 
        for n <- neighbours, do:
          send(pl, {:beb_broadcast, n, message, from})
      {:beb_broadcast, message, source} ->
        # IO.puts("HEREEEEE")
        send(app, {message, source})
    end
    next(pl, app, neighbours)
  end
end
