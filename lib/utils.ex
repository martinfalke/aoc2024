defmodule Utils do
  def read_input_file(day) do
    filepath = (day < 10 && "lib/inputs/day0#{day}.txt") || "lib/inputs/day#{day}.txt"
    {:ok, f} = File.read(filepath)
    f
  end

  def read_input_file(day, :example) do
    filepath =
      (day < 10 && "lib/inputs/example/day0#{day}.txt") || "lib/inputs/example/day#{day}.txt"

    {:ok, f} = File.read(filepath)
    f
  end

  def split_lines(file_contents) do
    lines = String.split(file_contents, "\n")
    lines
  end

  def remove_trailing_newline([head | tail]) when tail != [""],
    do: [head | remove_trailing_newline(tail)]
  def remove_trailing_newline([]), do: []
  def remove_trailing_newline([head | [""]]), do: [head]

  def init_day(day, nil) do
    fc = read_input_file(day)
    fc
  end

  def init_day(day, :example) do
    fc = read_input_file(day, :example)
    fc
  end
end
