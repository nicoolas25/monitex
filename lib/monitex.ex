defmodule Monitex do
  use Application

  def start(_type, _args) do
    Monitex.Supervisor.start_link
  end
end
