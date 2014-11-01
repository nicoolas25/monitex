defmodule Monitex.CLI do
  @default_updater 30_000
  @default_worker 3_000

  def main(args) do
    args |> parse_args |> process
  end

  def default_delays do
    %{updater: @default_updater, worker: @default_worker}
  end

  defp parse_args(args) do
    options = OptionParser.parse(
      args,
      switches: [help: :boolean, updater: :integer, worker: :integer],
      aliases: [h: :help, u: :updater, w: :worker]
    )

    case options do
      { [ help: true ], _, _}                       -> :help
      { [ updater: updater, worker: worker ], _, _} -> %{default_delays | updater: updater, worker: worker}
      { [ updater: updater ], _, _}                 -> %{default_delays | updater: updater}
      { [ worker: worker ], _, _}                   -> %{default_delays | worker: worker}
      _                                             -> default_delays
    end
  end

  defp process(:help) do
    IO.puts """
      Usage:
        monitex [options...]

      Options:
        -h        [--help]     Show this message
        -u <int>  [--updater]  Set the frequency of the account list updates (in ms)
        -w <int>  [--worker]   Set the frequency of the account message retrieval (in ms)
    """
    System.halt(0)
  end

  defp process(delays) do
    {:ok, pid} = Monitex.start(:normal, delays)
    ref = Process.monitor(pid)
    receive do
      msg = {'DOWN', ^ref, type, object, info} ->
        :io.format('~p\n', [msg])
        System.halt(1)
    end
  end
end
