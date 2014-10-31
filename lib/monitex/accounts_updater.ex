#
# It maintains a list of accounts to fetch. It will refresh the list
# periodically using its parameter. It will add children to the
# AccountFetcher of its supervisor for each discovered account. It
# will also delete the child if it disappear from the list.
#
defmodule Monitex.AccountsUpdater do
  use GenServer

  def start_link(delay, fetcher) when is_integer(delay) do
    {:ok, pid} = GenServer.start_link(__MODULE__, {delay, fetcher})
    Process.send_after(pid, :refresh, delay)

    IO.puts "AccountsUpdater #{:erlang.pid_to_list(pid)} is starting"

    {:ok, pid}
  end

  # Callbacks

  def init({delay, fetcher}) do
    state = %{delay: delay, fetcher: fetcher, counter: 0}
    {:ok, state}
  end

  def handle_info(:refresh, state) do
    delay = state[:delay]
    new_state = refresh_accounts(state)
    Process.send_after(self(), :refresh, delay)
    {:noreply, new_state}
  end

  defp refresh_accounts(state) do
    last_id = state[:counter] + 1
    supervisor = state[:fetcher]
    child_spec = Supervisor.Spec.worker(Monitex.AccountWorker, [], id: last_id)
    Supervisor.start_child(supervisor, child_spec)

    IO.puts "AccountsUpdater #{:erlang.pid_to_list(self)} is sending a new account: ##{last_id} to #{supervisor}."

    %{state | counter: last_id}
  end
end
