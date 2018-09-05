defmodule Assign1.CLI do
  def run(argv) do
    parse_args(argv)
  end

  def parse_args(argv) do
    parse =
      OptionParser.parse(argv,
        switches: [help: :boolean],
        aliases: [h: :help]
      )

    case parse do
      {[help: true], _, _} ->
        :help

      {_, [n, k], _} ->
        {n, k}
    end
  end
end
