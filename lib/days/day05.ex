defmodule Day5 do
  import Utils
  defp day(), do: 5

  # Part 1
  def add_map_value(map, key, value) do
    map |> Map.update(key, [value], fn existing_value -> [value | existing_value] end)
  end

  def parse_prio_rules(rules_raw) do
    rules_raw
    |> Enum.reduce(%{}, fn [before, later], acc -> add_map_value(acc, before, later) end)
  end

  def is_page_valid(blocked_page, %MapSet{} = validated_pages) when is_binary(blocked_page) do
    !MapSet.member?(validated_pages, blocked_page)
  end

  def is_update_valid(update, rules, validated_pages \\ MapSet.new())
  def is_update_valid([], _rules, _validated_pages), do: true

  def is_update_valid([next | rest_update], rules, validated_pages)
      when is_map(rules) do
    Map.get(rules, next, [])
    |> Enum.reduce_while(true, fn page, _ ->
      (is_page_valid(page, validated_pages) && {:cont, true}) || {:halt, false}
    end) &&
      is_update_valid(rest_update, rules, MapSet.put(validated_pages, next))
  end

  def get_valid_updates(updates_raw, rules) do
    updates_raw |> Enum.filter(fn update -> is_update_valid(update, rules) end)
  end

  def get_middle_page(update) do
    update
    |> length()
    |> div(2)
    |> then(fn i_mid -> Enum.at(update, i_mid) end)
  end

  def run_p(use_example) do
    [rules_raw, updates_raw] =
      day()
      |> init_day(use_example)
      |> String.split("\n\n")
      |> Enum.map(fn section ->
        split_lines(section)
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(&String.split(&1, ["|", ","]))
      end)

    rules = parse_prio_rules(rules_raw)
    valid_updates = get_valid_updates(updates_raw, rules)
    valid_updates |> Enum.map(&get_middle_page/1) |> Enum.map(&String.to_integer/1) |> Enum.sum()
  end

  # Part 2
  def parse_prio_rules(rules_raw, :reverse_mapping) do
    rules_raw
    |> Enum.reduce(%{}, fn [before, later], acc -> add_map_value(acc, later, before) end)
  end

  def get_invalid_updates(updates_raw, rules) do
    updates_raw
    |> Enum.filter(fn update -> !is_update_valid(update, rules) end)
  end

  def get_independent_pages(rules, update) do
    update_pages = update |> MapSet.new()
    source_pages = rules |> Map.keys() |> MapSet.new()
    MapSet.difference(update_pages, source_pages) |> MapSet.to_list()
  end

  def filter_update_rules(update_rules, update) do
    # for every key, remove all list elements in its value that are not in update
    update_rules
    |> Enum.reduce(%{}, fn {key, dependencies}, filtered_rules ->
      dependencies
      |> Enum.filter(&(&1 in update))
      |> then(fn filtered_dependencies ->
        case filtered_dependencies do
          [] -> filtered_rules
          _ -> Map.put(filtered_rules, key, filtered_dependencies)
        end
      end)
    end)
  end

  def sort_pages_topologically(rules, pages, [], sorted_pages) when is_list(sorted_pages) do
    {rules, pages, [], sorted_pages}
  end

  def sort_pages_topologically(rules, pages, independent_pages, sorted_pages)
      when is_list(sorted_pages) do
    p = List.first(independent_pages)
    independent_pages = List.delete(independent_pages, p)
    sorted_pages = [p | sorted_pages]

    dependents = rules |> Map.keys() |> Enum.filter(fn key -> p in Map.get(rules, key, []) end)

    {rules, pages, independent_pages, sorted_pages} =
      dependents
      |> Enum.reduce({rules, pages, independent_pages, sorted_pages}, fn key,
                                                                         {rules, pages,
                                                                          independent_pages,
                                                                          sorted_pages} ->
        {_, rules} = Map.get_and_update!(rules, key, &{&1, List.delete(&1, p)})

        if Map.get(rules, key, []) == [] do
          {Map.delete(rules, key), pages, independent_pages ++ [key], sorted_pages}
        else
          {rules, pages, independent_pages, sorted_pages}
        end
      end)

    sort_pages_topologically(rules, pages, independent_pages, sorted_pages)
  end

  def sort_pages_topologically(rules, pages, independent_pages, :start) do
    # apply Kahn's algorithm
    {rules, _pages, _independent_pages, sorted_pages} =
      sort_pages_topologically(rules, pages, independent_pages, [])

    if Map.keys(rules) != [] do
      raise "Graph has at least one cycle, is not connected, or was implemented incorrectly"
    end

    sorted_pages
  end

  def correct_invalid_updates(invalid_updates, rules) do
    corrected_updates =
      invalid_updates
      |> Enum.map(fn update -> {rules |> Map.take(update), update} end)
      |> Enum.map(fn {update_rules, update} ->
        update_rules
        |> filter_update_rules(update)
        |> then(&{&1, update, get_independent_pages(&1, update)})
      end)
      |> Enum.map(fn {update_rules, update, independent_pages} ->
          sort_pages_topologically(update_rules, update, independent_pages, :start)
      end)

    corrected_updates
  end

  def run_q(use_example) do
    [rules_raw, updates_raw] =
      day()
      |> init_day(use_example)
      |> String.split("\n\n")
      |> Enum.map(fn section ->
        split_lines(section)
        |> remove_trailing_newline()
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(&String.split(&1, ["|", ","]))
      end)

    validity_rules = parse_prio_rules(rules_raw)
    correction_rules = parse_prio_rules(rules_raw, :reverse_mapping)

    corrected_updates_sum =
      get_invalid_updates(updates_raw, validity_rules)
      |> correct_invalid_updates(correction_rules)
      |> Enum.map(&get_middle_page/1)
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()

    corrected_updates_sum
  end
end
