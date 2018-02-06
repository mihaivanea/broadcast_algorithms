defmodule PL do

  def start() do
    IO.puts(["PL at ", DNS.my_ip_addr])
    next(nil)
  end

  defp next(app_pl) do
    receive do
      {:bind, new_app_pl} -> 
        next(new_app_pl)
      {:switch, app_pl, app} ->
        p2p_link(app_pl, app)
    end
  end

  defp p2p_link(app_pl, app) do
    receive do
      {:broadcast, max_broadcasts, timeout} ->
        send(app, {:broadcast, max_broadcasts, timeout})
        p2p_link(app_pl, app)
      {:pl_deliver, destination, message} ->
        IO.puts("HERE")
        send(app_pl[destination], message)
        p2p_link(app_pl, app)
    end
  end

end
