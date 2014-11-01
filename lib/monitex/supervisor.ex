#
# Main supervisor for the application.
#
# It starts one AccountsManager.
#
defmodule Monitex.Supervisor do
  use Supervisor

  def start_link(delays) do
    Supervisor.start_link(__MODULE__, delays)
  end

  # Callbacks

  def init(delays) do
    children = [
      worker(Monitex.AccountsManager, [delays])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
