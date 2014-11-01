defmodule Monitex.AccountWorker do
  use GenServer

  def start_link(delay) do
    {:ok, pid} = GenServer.start_link(__MODULE__, delay)
    Process.send_after(pid, :refresh, delay)

    IO.puts "AccountWorker #{:erlang.pid_to_list(pid)} is starting"

    {:ok, pid}
  end

  # Callbacks

  def init(delay) do
    state = %{delay: delay, counter: 0}
    {:ok, state}
  end

  def handle_info(:refresh, state) do
    IO.puts "AccountWorker #{:erlang.pid_to_list(self)} is triggered!"

    delay = state[:delay]
    Process.send_after(self, :refresh, delay)
    {:noreply, state}
  end


end
