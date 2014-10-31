#
# It supervise nothing at the begining but over time an AccountUpdater
# will add childs to monitor.
#
defmodule Monitex.AccountsFetcher do
  use Supervisor

  def start_link(name) do
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    IO.puts "AccountsFetcher #{:erlang.pid_to_list(self)} is wainting for new childs"

    children = []
    supervise(children, strategy: :one_for_one)
  end
end
