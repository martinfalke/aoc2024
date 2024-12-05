defmodule Parser do
  import NimbleParsec

  left_num =
    choice([
      string(" ") |> ignore(),
      integer(5) |> concat(string("\n")) |> ignore(),
      integer(5)
    ])

  right_num =
    choice([
      ignore(string(" ")),
      integer(5) |> lookahead_not(string(" ")),
      string("\n") |> ignore(),
      integer(5) |> ignore()
    ])

  defparsec(:left_col, repeat(left_num))
  defparsec(:right_col, repeat(right_num))
end

defmodule Day1 do
  import Utils
  require Parser
  defp day(), do: 1

  # Part 1
  def run_p(use_example) do
    filecontent = day() |> init_day(use_example)
    {:ok, left, _, _, _, _} = filecontent |> Parser.left_col()
    left = Enum.sort(left)
    {:ok, right, _, _, _, _} = filecontent |> Parser.right_col()
    right = Enum.sort(right)
    distance_sum = Enum.zip(left, right) |> Enum.reduce(0, fn {x, y}, acc -> acc + abs(x - y) end)
    distance_sum
  end

  # Part 2
  def get_identical_count(x, right_list) do
    start = Enum.find_index(right_list, fn rx -> rx == x end)

    if start == nil do
      0
    else
      Enum.count(right_list, fn y -> y == x end)
    end
  end

  def run_q(use_example) do
    filecontent = day() |> init_day(use_example)
    {:ok, left, _, _, _, _} = filecontent |> Parser.left_col()
    left = Enum.sort(left)
    {:ok, right, _, _, _, _} = filecontent |> Parser.right_col()
    right = Enum.sort(right)

    similarity_score =
      Enum.map(left, fn x -> {x, get_identical_count(x, right)} end)
      |> Enum.reduce(0, fn {x, n}, acc -> acc + x * n end)

    similarity_score
  end
end
