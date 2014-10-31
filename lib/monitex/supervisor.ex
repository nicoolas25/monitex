#
# Main supervisor for the application.
#
# It starts one AccountsManager.
#
defmodule Monitex.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  # Callbacks

  def init(:ok) do
    children = [
      worker(Monitex.AccountsManager, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
