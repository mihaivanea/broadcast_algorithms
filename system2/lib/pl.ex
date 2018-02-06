defmodule PL do

  def start() do
    IO.puts(["PL at ", DNS.my_ip_addr])
    next(nil)
  end

  defp next(app_pl) do
    receive do
      {:bind, new_app_pl} -> 
        next(new_app_pl)
      {:switch, app_pl} ->
        p2p_link()
    end
  end

  defp p2p_link() do
    IO.puts("HERE")
  end

end
