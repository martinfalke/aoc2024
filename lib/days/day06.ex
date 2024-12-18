defmodule Day6 do
  import Utils
  @day 6

  # Part 1
  def get_cell_types(lab_map, map_coords) do
    map_coords
    |> Enum.reduce(%{}, fn {r, c}, cell_types ->
      case Enum.at(lab_map, r) |> Enum.at(c) do
        ?^ ->
          :guard

        ?# ->
          :obstruction

        ?. ->
          :empty
      end
      |> then(&Map.put(cell_types, {r, c}, &1))
    end)
  end

  def get_next_direction(
        cell_types,
        map_length,
        {r, c} = _current_pos,
        {dr, dc} = _current_direction
      ) do
    forward_pos = {r + dr, c + dc}
    {f_r, f_c} = forward_pos

    cond do
      f_r < 0 or f_c < 0 or f_r >= map_length or f_c >= map_length ->
        {dr, dc}

      cell_types[{f_r, f_c}] == :obstruction ->
        {dc, -dr} # rotate 90 degrees clockwise

      true ->
        {dr, dc}
    end
  end

  def visit_coords(visited_map, _cell_types, map_length, {r, c} = _guard_pos, _current_direction)
      when r < 0 or c < 0 or r >= map_length or c >= map_length,
      do: visited_map

  def visit_coords(visited_map, cell_types, map_length, {r, c} = guard_pos, current_direction) do
    visited_map = visited_map |> Map.update(guard_pos, 1, &(&1 + 1))
    {new_dr, new_dc} = get_next_direction(cell_types, map_length, guard_pos, current_direction)
    visit_coords(visited_map, cell_types, map_length, {r + new_dr, c + new_dc}, {new_dr, new_dc})
  end

  def get_visited_map(lab_map, map_coords) do
    cell_types = get_cell_types(lab_map, map_coords)

    guard_pos =
      Enum.reduce(cell_types, nil, fn {coord, cell_type}, acc ->
        (cell_type == :guard && coord) || acc
      end)

    init_direction = {-1, 0}

    visited_map = visit_coords(%{}, cell_types, length(lab_map), guard_pos, init_direction)
    {visited_map, guard_pos}
  end

  def run_p(use_example) do
    lab_map =
      @day
      |> init_day(use_example)
      |> split_lines(:no_trail)
      |> Enum.map(&String.to_charlist/1)

    num_cols = List.first(lab_map) |> length()
    num_rows = length(lab_map)

    map_coords =
      0..(num_rows - 1)
      |> Enum.map(fn r -> 0..(num_cols - 1) |> Enum.map(fn c -> {r, c} end) end)
      |> List.flatten()

    num_visited = get_visited_map(lab_map, map_coords) |> elem(0) |> Map.keys() |> length()
    num_visited
  end

  # Part 2
  def is_map_loop(
        _visited_mapset,
        _cell_types,
        map_length,
        {r, c} = _guard_pos,
        _current_direction
      )
      when r < 0 or c < 0 or r >= map_length or c >= map_length,
      do: false

  def is_map_loop(
        visited_mapset,
        cell_types,
        map_length,
        {r, c} = _guard_pos,
        {dr, dc} = current_direction
      ) do
    cond do
      MapSet.member?(visited_mapset, {r, c, dr, dc}) ->
        true

      true ->
        updated_visited_mapset = MapSet.put(visited_mapset, {r, c, dr, dc})

        {new_r, new_c} = {r + dr, c + dc}

        {new_dr, new_dc} =
          get_next_direction(cell_types, map_length, {r, c}, current_direction)

        {new_r, new_c} =
          cond do
            new_dr == dr && new_dc == dc -> {new_r, new_c}
            true -> {r, c} # test the new direction from the same position before proceeding
          end

        is_map_loop(
          updated_visited_mapset,
          cell_types,
          map_length,
          {new_r, new_c},
          {new_dr, new_dc}
        )
    end
  end

  def get_obstructed_loops(lab_map, map_coords, searchable_coords) do
    cell_types = get_cell_types(lab_map, map_coords)

    guard_pos =
      Enum.reduce(cell_types, nil, fn {coord, cell_type}, acc ->
        (cell_type == :guard && coord) || acc
      end)

    init_direction = {-1, 0}

    tracked_obstructed_maps =
      searchable_coords
      |> Enum.map(fn obst_pos ->
        is_map_loop(
          MapSet.new(),
          Map.put(cell_types, obst_pos, :obstruction),
          length(lab_map),
          guard_pos,
          init_direction
        )
      end)

    tracked_obstructed_maps |> Enum.filter(&(&1 == true))
  end

  def run_q(use_example) do
    lab_map =
      @day
      |> init_day(use_example)
      |> split_lines(:no_trail)
      |> Enum.map(&String.to_charlist/1)

    num_cols = List.first(lab_map) |> length()
    num_rows = length(lab_map)

    map_coords =
      0..(num_rows - 1)
      |> Enum.map(fn r -> 0..(num_cols - 1) |> Enum.map(fn c -> {r, c} end) end)
      |> List.flatten()

    # only coordinates visited in the original map can change the guard's route
    {visited_map, guard_pos} = get_visited_map(lab_map, map_coords)

    searchable_coords = visited_map |> Map.delete(guard_pos) |> Map.keys() |> MapSet.new()

    obstructed_loops =
      searchable_coords
      |> MapSet.to_list()
      |> then(&get_obstructed_loops(lab_map, map_coords, &1))

    obstructed_loops |> length()
  end
end
