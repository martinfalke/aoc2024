defmodule XmasParser do
  import NimbleParsec

  xmas = string("XMAS")
  parse_xmas = choice([xmas, utf8_char([]) |> ignore()])

  mas = string("MAS")
  parse_mas = choice([mas, utf8_char([]) |> ignore()])

  defparsec(:find_xmases, repeat(parse_xmas))
  defparsec(:find_mases, repeat(parse_mas))
end

defmodule TensorTransform do
  require Nx
  def pattern_length, do: 4

  def left_to_right(tensor) do
    tensor
  end

  def right_to_left(tensor) do
    tensor |> Nx.reverse(axes: [:col])
  end

  def top_to_bottom(tensor) do
    tensor |> Nx.transpose()
  end

  def bottom_to_top(tensor) do
    tensor |> Nx.reverse(axes: [:row]) |> top_to_bottom()
  end

  def top_left_to_bottom_right(tensor) do
    tensor
    |> Nx.shape()
    |> elem(0)
    |> then(fn num_rows -> num_rows - pattern_length() end)
    |> then(fn diag_offset -> Range.new(-1 * diag_offset, diag_offset) end)
    |> Enum.map(fn diag_idx -> Nx.take_diagonal(tensor, offset: diag_idx) end)
  end

  def top_right_to_bottom_left(tensor) do
    tensor |> right_to_left() |> top_left_to_bottom_right()
  end

  def bottom_left_to_top_right(tensor) do
    tensor |> bottom_to_top() |> top_left_to_bottom_right()
  end

  def bottom_right_to_top_left(tensor) do
    tensor |> right_to_left() |> bottom_left_to_top_right()
  end

  def get_all_directions(tensor) do
    [
      &left_to_right/1,
      &right_to_left/1,
      &top_to_bottom/1,
      &bottom_to_top/1,
      &top_left_to_bottom_right/1,
      &top_right_to_bottom_left/1,
      &bottom_left_to_top_right/1,
      &bottom_right_to_top_left/1
    ]
    |> Stream.map(& &1.(tensor))
  end

  def get_main_diags(tensor) do
    [
      # TL->BR
      fn t -> Nx.take_diagonal(t) end,
      # TR -> BL
      fn t -> right_to_left(t) |> Nx.take_diagonal() end,
      # BL -> TR
      fn t -> bottom_to_top(t) |> Nx.take_diagonal() end,
      # BR -> TL
      fn t -> right_to_left(t) |> bottom_to_top() |> Nx.take_diagonal() end
    ]
    |> Stream.map(& &1.(tensor))
  end
end

defmodule Day4 do
  import Utils
  import TensorTransform
  require Nx
  defp day(), do: 4

  # Part 1
  def count_xmases(slice) when is_binary(slice) do
    {:ok, parsed_xmases, "", _, _, _} =
      slice |> XmasParser.find_xmases()

    length(parsed_xmases)
  end

  def directions_to_strings(directions) do
    directions
    |> Stream.map(fn t ->
      cond do
        is_list(t) -> t
        true -> [t]
      end
    end)
    |> Enum.reduce([], &(&2 ++ &1))
    |> Enum.map(fn tl ->
      case Nx.shape(tl) do
        {x, _} -> 0..(x - 1) |> Enum.map(fn i -> tl[i][..] |> Nx.to_list() end)
        _ -> Nx.to_list(tl)
      end
    end)
    |> Enum.reduce([], fn l, acc ->
      cond do
        is_list(List.first(l)) ->
          acc ++ Enum.reduce(l, [], fn l, mergelist -> mergelist ++ [List.to_string(l)] end)

        true ->
          acc ++ [List.to_string(l)]
      end
    end)
  end

  def run_p(use_example) do
    lines = day() |> init_day(use_example) |> split_lines() |> remove_trailing_newline()

    wordmatrix =
      Enum.map(lines, &String.to_charlist/1)
      |> Nx.tensor(names: [:row, :col], type: :u8)

    wordmatrix
    |> get_all_directions()
    |> directions_to_strings()
    |> Enum.map(&count_xmases(&1))
    |> Enum.sum()
  end

  # Part 2
  def chunk_tensor_3by3(tensor) do
    tensor
    |> Nx.shape()
    |> then(fn {num_rows, num_cols} -> {num_rows - 3, num_cols - 3} end)
    |> then(fn {r_offset, c_offset} -> {Range.new(0, r_offset), Range.new(0, c_offset)} end)
    |> then(fn {r_range, c_range} ->
      Enum.map(r_range, fn r_idx -> Enum.map(c_range, fn c_idx -> {r_idx, c_idx} end) end)
    end)
    |> Enum.reduce([], fn x, acc -> acc ++ x end)
    |> Enum.map(fn {i, j} -> Nx.slice(tensor, [i, j], [3, 3]) end)
  end

  def count_mases(slice) when is_binary(slice) do
    {:ok, parsed_xmases, "", _, _, _} =
      slice |> XmasParser.find_mases()

    length(parsed_xmases)
  end

  def get_num_x_mases(chunks_mas_counts) when is_list(chunks_mas_counts) do
    chunks_mas_counts
    # 2 MAS in the diagonals of a chunk is an X-MAS
    |> Enum.filter(fn x -> x == 2 end)
    |> Enum.count()
  end

  def run_q(use_example) do
    lines = day() |> init_day(use_example) |> split_lines() |> remove_trailing_newline()

    wordmatrix =
      Enum.map(lines, &String.to_charlist/1)
      |> Nx.tensor(names: [:row, :col], type: :u8)

    wordmatrix
    |> chunk_tensor_3by3()
    |> Enum.map(&get_main_diags(&1))
    |> Enum.map(&directions_to_strings(&1))
    |> Enum.map(fn diag -> is_list(diag) && Enum.join(diag, "u") || diag end)
    |> Enum.map(&count_mases(&1))
    |> get_num_x_mases()
  end
end
