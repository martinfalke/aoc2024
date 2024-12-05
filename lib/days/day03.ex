defmodule MulParser do
  import NimbleParsec

  valid_mul =
    string("mul(")
    |> concat(integer(min: 1, max: 3))
    |> concat(string(","))
    |> concat(integer(min: 1, max: 3))
    |> concat(string(")"))

  ignore_all =
    utf8_char([]) |> ignore()

  enable_instr = string("do()")
  disable_instr = string("don't()")

  muls_until_disable =
    choice([valid_mul, lookahead_not(disable_instr) |> concat(ignore_all)]) |> repeat()

  ignore_until_enable = lookahead_not(enable_instr) |> concat(ignore_all) |> repeat()

  enabled_segment = enable_instr |> concat(muls_until_disable)
  disabled_segment = disable_instr |> concat(ignore_until_enable)

  defparsec(:valid_muls, choice([valid_mul, ignore_all]) |> repeat())

  defparsec(
    :valid_muls_with_toggle,
    choice([valid_mul, enabled_segment, disabled_segment, ignore_all]) |> repeat()
  )
end

defmodule Day3 do
  import Utils
  defp day(), do: 3

  def add_product([]), do: 0

  def add_product([x1, x2 | tail]) do
    x1 * x2 + add_product(tail)
  end

  # Part 1
  def run_p(use_example) do
    instr_memory = day() |> init_day(use_example)
    {:ok, parsed_muls, "", _, _, _} = instr_memory |> MulParser.valid_muls()
    parsed_muls |> Enum.filter(fn token -> is_integer(token) end) |> add_product()
  end

  # Part 2
  def run_q(use_example) do
    instr_memory = day() |> init_day(use_example)
    {:ok, parsed_muls, "", _, _, _} = instr_memory |> MulParser.valid_muls_with_toggle()
    parsed_muls |> Enum.filter(fn token -> is_integer(token) end) |> add_product()
  end
end
