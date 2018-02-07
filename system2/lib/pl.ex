# Mihail Vanea (mv1315)

defmodule PL do

  def start() do
    IO.puts(["PL at ", DNS.my_ip_addr])
    next()
  end

  defp next() do
    receive do
      {:switch, app_pl, app} ->
        p2p_link(app_pl, app)
    end
  end

  defp p2p_link(app_pl, app) do
    receive do
      {:broadcast, max_broadcasts, timeout} ->
        send(app, {:broadcast, max_broadcasts, timeout})
        p2p_link(app_pl, app)
      {:pl_deliver, :msg, source} ->
        send(app, {:msg, source})
        p2p_link(app_pl, app)
      {destination, :msg, source} ->
        send(app_pl[destination], {:pl_deliver, :msg, source})
        p2p_link(app_pl, app)
    end
  end

end
