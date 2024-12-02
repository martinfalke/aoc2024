defmodule Utils do
  import NimbleParsec

  def read_input_file(day) do
    filepath = if day < 10 do
      "lib/inputs/day0#{day}.txt"
    else
      "lib/inputs/day#{day}.txt"
    end

    {:ok, f} = File.read(filepath)
    f
  end

  def split_lines(file_contents) do
    lines = String.split(file_contents, "\n")
    lines
  end

  def init_day(day) do
    fc = read_input_file(day)
    split_lines(fc)
  end
end
