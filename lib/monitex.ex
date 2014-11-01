defmodule Monitex do
  use Application

  def start(_type, delays) do
    Monitex.Supervisor.start_link(delays)
  end
end
