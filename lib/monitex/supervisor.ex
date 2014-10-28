defmodule Monitex.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  # Callbacks

  def init(:ok) do
    IO.puts "Launching..."
    children = [ ]
    supervise(children, strategy: :one_for_one)
  end
end
