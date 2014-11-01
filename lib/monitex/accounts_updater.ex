#
# It maintains a list of accounts to fetch. It will refresh the list
# periodically using its parameter. It will add children to the
# AccountFetcher of its supervisor for each discovered account. It
# will also delete the child if it disappear from the list.
#
defmodule Monitex.AccountsUpdater do
  use GenServer

  def start_link(delays, fetcher) do
    {:ok, pid} = GenServer.start_link(__MODULE__, {delays, fetcher})
    Process.send_after(pid, :refresh, delays[:updater])

    IO.puts "AccountsUpdater #{:erlang.pid_to_list(pid)} is starting"

    {:ok, pid}
  end

  # Callbacks

  def init({delays, fetcher}) do
    state = %{delays: delays, fetcher: fetcher, counter: 0}
    {:ok, state}
  end

  def handle_info(:refresh, state) do
    delay = state[:delays][:updater]
    new_state = refresh_accounts(state)
    Process.send_after(self, :refresh, delay)
    {:noreply, new_state}
  end

  defp refresh_accounts(state) do
    delay = state[:delays][:worker]
    last_id = state[:counter] + 1
    supervisor = state[:fetcher]
    child_spec = Supervisor.Spec.worker(Monitex.AccountWorker, [delay], id: last_id)
    Supervisor.start_child(supervisor, child_spec)

    IO.puts "AccountsUpdater #{:erlang.pid_to_list(self)} is sending a new account: ##{last_id} to #{supervisor}."

    %{state | counter: last_id}
  end
end
