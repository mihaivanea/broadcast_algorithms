# Mihail Vanea (mv1315)

defmodule PL do

  def start() do
    IO.puts(["PL at ", DNS.my_ip_addr])
    next()
  end

  defp next() do
    receive do
      {:switch, app_pl, app, beb} ->
        p2p_link(app_pl, app, beb)
    end
  end

  defp p2p_link(app_pl, app, beb) do
    receive do
      {:broadcast, max_broadcasts, timeout} ->
        send(app, {:broadcast, max_broadcasts, timeout})
      {:pl_deliver, message, source} ->
        send(beb, {:beb_broadcast, message, source})
      {:beb_broadcast, destination, message, source} ->
        send(app_pl[destination], {:pl_deliver, message, source})
    end
    p2p_link(app_pl, app, beb)
  end

end
