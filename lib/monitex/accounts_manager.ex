#
# This supervisor manage a pool of accounts.
#
# It starts an AccountUpdater and an AccountFetcher.
#
defmodule Monitex.AccountsManager do
  use Supervisor

  def start_link do
    update_delay = 5_000 # 5s
    Supervisor.start_link(__MODULE__, update_delay)
  end

  # Callbacks

  def init(update_delay) do
    children = [
      supervisor(Monitex.AccountsFetcher, [:monitex_fetcher]),
      worker(Monitex.AccountsUpdater, [update_delay, :monitex_fetcher]),
    ]
    supervise(children, strategy: :one_for_all)
  end
end
