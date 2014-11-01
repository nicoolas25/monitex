#
# This supervisor manage a pool of accounts.
#
# It starts an AccountUpdater and an AccountFetcher.
#
defmodule Monitex.AccountsManager do
  use Supervisor

  def start_link(delays) do
    Supervisor.start_link(__MODULE__, delays)
  end

  # Callbacks

  def init(delays) do
    children = [
      supervisor(Monitex.AccountsFetcher, [:monitex_fetcher]),
      worker(Monitex.AccountsUpdater, [delays, :monitex_fetcher]),
    ]
    supervise(children, strategy: :one_for_all)
  end
end
