defmodule Day2 do
  import Utils
  defp day(), do: 2

  # Part 1
  def is_report_valid(report, validity_functions) when is_list(validity_functions) do
    Enum.any?(validity_functions, fn foo -> is_report_valid(report, foo) end)
  end

  def is_report_valid([xi, xj | rest_report], validity_func) when rest_report == [],
    do: validity_func.(xi, xj)

  def is_report_valid([xi, xj | rest_report], validity_func) do
    validity_func.(xi, xj) && is_report_valid([xj | rest_report], validity_func)
  end

  def is_decreasing(xi, xj, lo, hi) do
    diff = xi - xj
    lo <= diff && diff <= hi
  end

  def is_increasing(xi, xj, lo, hi) do
    diff = xj - xi
    lo <= diff && diff <= hi
  end

  def get_validity_functions() do
    lo = 1
    hi = 3

    funcs = [
      fn xi, xj -> is_increasing(xi, xj, lo, hi) end,
      fn xi, xj -> is_decreasing(xi, xj, lo, hi) end
    ]

    funcs
  end

  def run_p(use_example) do
    reports = day() |> init_day(use_example) |> split_lines() |> remove_trailing_newline()

    level_reports =
      reports
      |> Enum.map(fn x -> String.split(x, " ") |> Enum.map(&String.to_integer/1) end)

    validity_functions = get_validity_functions()

    num_valid = Enum.count(level_reports, fn r -> is_report_valid(r, validity_functions) end)
    num_valid
  end

  # Part 2
  # 'loo' = leave one out
  def get_report_loo_subsets(report) do
    last_index = length(report) - 1
    subsets = [report | Enum.map(0..last_index, fn i -> List.delete_at(report, i) end)]
    subsets
  end

  def is_any_subset_valid(subsets, valid_funcs) do
    Enum.any?(subsets, fn subset -> is_report_valid(subset, valid_funcs) end)
  end

  def run_q(use_example) do
    reports = day() |> init_day(use_example) |> split_lines() |> remove_trailing_newline()

    level_reports =
      reports
      |> Enum.map(fn x -> String.split(x, " ") |> Enum.map(&String.to_integer/1) end)

    report_loo_subsets = Enum.map(level_reports, &get_report_loo_subsets/1)

    validity_functions = get_validity_functions()

    num_valid =
      Enum.count(report_loo_subsets, fn rls ->
        is_any_subset_valid(rls, validity_functions)
      end)

    num_valid
  end
end
