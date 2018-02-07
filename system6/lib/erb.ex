# Mihail Vanea (mv1315)

defmodule ERB do

  def start() do
    receive do
      {:bind, beb, app} -> 
        next(beb, app, MapSet.new())
    end
  end

  defp next(beb, app, delivered) do
    receive do
      {:broadcast, message} -> 
        send(beb, {:rb_broadcast, message, app})
        next(beb, app, delivered)
      {:beb_deliver, message, source} ->
        if MapSet.member?(delivered, message) do
          next(beb, app, delivered)
        else
          send(app, {message, source})
          send(beb, {:rb_broadcast, message, source})
          next(beb, app, MapSet.put(delivered, message))
        end
    end
  end

end
