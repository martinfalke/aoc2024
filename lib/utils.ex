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

  def split_lines(file_contents, rm_trail \\ :trail)
  def split_lines(file_contents, :no_trail) do
    split_lines(file_contents, :trail) |> remove_trailing_newline()
  end
  def split_lines(file_contents, _rm_trail) do
    lines = String.split(file_contents, "\n")
    lines
  end

  def remove_trailing_newline([head | tail]) when tail != [""],
    do: [head | remove_trailing_newline(tail)]
  def remove_trailing_newline([]), do: []
  def remove_trailing_newline([head | [""]]), do: [head]

  @spec get_2d_map_size(list(list())) :: {integer(), integer()}
  def get_2d_map_size(map) do
    num_rows = length(map)
    num_cols = List.first(map) |> length()
    {num_rows, num_cols}
  end

  @spec create_2d_map_coordinates(list(list())) :: list()
  def create_2d_map_coordinates(map) do
    {num_rows, num_cols} = get_2d_map_size(map)
    map_coords =
      0..(num_rows - 1)
      |> Enum.map(fn r -> 0..(num_cols - 1) |> Enum.map(fn c -> {r, c} end) end)
      |> List.flatten()
    map_coords
  end

  def init_day(day, nil) do
    fc = read_input_file(day)
    fc
  end

  def init_day(day, :example) do
    fc = read_input_file(day, :example)
    fc
  end
end
