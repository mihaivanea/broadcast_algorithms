# Mihail Vanea (mv1315)

defmodule LPL do

  def start() do
    IO.puts(["LPL at ", DNS.my_ip_addr])
    reliability = 50
    next(reliability)
  end

  defp next(reliability) do
    receive do
      {:switch, app_pl, app, beb} ->
        lossy_p2p_link(app_pl, app, beb, reliability)
    end
  end

  defp lossy_p2p_link(app_pl, app, beb, reliability) do
    receive do
      {:broadcast, max_broadcasts, timeout} ->
        send(app, {:broadcast, max_broadcasts, timeout})
      {:pl_deliver, message, source} ->
        send(beb, {:beb_broadcast, message, source})
      {:beb_broadcast, destination, message, source} ->
        lossy_send(app_pl[destination], {:pl_deliver, message, source}, reliability)
    end
    lossy_p2p_link(app_pl, app, beb, reliability)
  end

  defp lossy_send(destination, message, reliability) do
    if :rand.uniform(100) <= reliability do
      send(destination, message)
    end
  end

end
