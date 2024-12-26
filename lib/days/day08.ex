defmodule Day8 do
  import Utils
  @day 8

  # Part 1

  @spec get_antenna_frequencies(list(list(integer()))) :: map()
  def get_antenna_frequencies(city_map) do
    coords = Utils.create_2d_map_coordinates(city_map)

    [coords, List.flatten(city_map)]
    |> List.zip()
    |> Enum.reduce(%{}, fn {{r, c}, cell}, acc ->
      case cell do
        ?. -> acc
        _ -> Map.update(acc, cell, [{r, c}], fn existing -> [{r, c} | existing] end)
      end
    end)
  end

  @spec get_pair_antinodes(
          {integer(), integer()},
          {integer(), integer()},
          integer(),
          integer(),
          integer(),
          integer(),
          boolean()
        ) ::
          list()
  def get_pair_antinodes({r1, c1}, {r2, c2}, r_diff, c_diff, num_rows, num_cols, is_repeating)
      when not is_repeating do
    [{r1 - r_diff, c1 - c_diff}, {r2 + r_diff, c2 + c_diff}]
    |> Enum.filter(fn {r, c} -> r >= 0 && c >= 0 && r < num_rows && c < num_cols end)
  end

  def get_pair_antinodes({r1, c1}, {_r2, _c2}, r_diff, c_diff, _num_rows, num_cols, is_repeating)
      when is_repeating do
    # Part 2
    # y = mx + b
    m = r_diff / c_diff
    b = r1 - m * c1

    0..(num_cols - 1)
    |> Enum.map(fn x ->
      y_raw = m * x + b
      y = round(y_raw)
      y_delta = abs(y_raw - y)

      cond do
        y < 0 || y >= num_cols -> nil
        y_delta >= 10 ** -5 -> nil
        true -> {y, x}
      end
    end)
    |> Enum.filter(& &1)
  end

  @spec add_antenna_antinodes(
          {integer(), integer()},
          MapSet.t(),
          list({integer(), integer()}),
          {integer(), integer()}
        ) :: MapSet.t()
  def add_antenna_antinodes(
        {r_i, c_i} = _antenna,
        acc,
        frequency_antennas,
        {num_rows, num_cols} = _map_size,
        is_repeating \\ false
      ) do
    frequency_antennas
    |> Enum.filter(fn {r_j, c_j} -> r_i != r_j || c_i != c_j end)
    |> Enum.reduce(acc, fn {r_j, c_j}, acc ->
      r_diff = r_j - r_i
      c_diff = c_j - c_i

      get_pair_antinodes({r_i, c_i}, {r_j, c_j}, r_diff, c_diff, num_rows, num_cols, is_repeating)
      |> Enum.reduce(acc, fn {r, c}, acc_x ->
        MapSet.put(acc_x, {r, c})
      end)
    end)
  end

  @spec merge_antinode_locations(list(MapSet.t())) :: any()
  def merge_antinode_locations(all_antinodes) do
    all_antinodes
    |> Enum.reduce(MapSet.new(), fn freq_antinodes, acc -> MapSet.union(freq_antinodes, acc) end)
  end

  def run_p(use_example) do
    city_map =
      @day |> init_day(use_example) |> split_lines(:no_trail) |> Enum.map(&String.to_charlist/1)

    {num_rows, num_cols} = Utils.get_2d_map_size(city_map)
    frequencies = city_map |> get_antenna_frequencies()

    frequencies
    |> Map.keys()
    |> Enum.map(fn freq ->
      Map.get(frequencies, freq)
      |> then(
        &Enum.reduce(&1, MapSet.new(), fn {r, c}, acc ->
          add_antenna_antinodes({r, c}, acc, &1, {num_rows, num_cols})
        end)
      )
    end)
    |> merge_antinode_locations()
    |> MapSet.size()
  end

  # Part 2
  def run_q(use_example) do
    city_map =
      @day |> init_day(use_example) |> split_lines(:no_trail) |> Enum.map(&String.to_charlist/1)

    {num_rows, num_cols} = Utils.get_2d_map_size(city_map)
    frequencies = city_map |> get_antenna_frequencies()

    frequencies
    |> Map.keys()
    |> Enum.map(fn freq ->
      Map.get(frequencies, freq)
      |> then(
        &Enum.reduce(&1, MapSet.new(), fn {r, c}, acc ->
          add_antenna_antinodes({r, c}, acc, &1, {num_rows, num_cols}, true)
        end)
      )
    end)
    |> merge_antinode_locations()
    |> MapSet.size()
  end
end
