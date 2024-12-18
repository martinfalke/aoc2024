defmodule Day7 do
  import Utils
  @day 7

  # Part 1
  def parse_equations(input_lines) do
    input_lines
    |> Enum.map(&String.split(&1, ":"))
    |> Enum.map(&List.to_tuple/1)
    |> Enum.map(fn {result, operands} ->
      String.split(operands)
      |> Enum.map(&String.to_integer/1)
      |> then(&{String.to_integer(result), &1})
    end)
  end

  def test_addition(result, acc, [last_operand]) do
    acc + last_operand == result
  end

  def test_addition(result, acc, [operand | remaining_operands]) do
    acc = acc + operand

    acc <= result &&
      (test_addition(result, acc, remaining_operands) ||
         test_multiplication(result, acc, remaining_operands))
  end

  def test_multiplication(result, acc, [last_operand]) do
    acc * last_operand == result
  end

  def test_multiplication(result, acc, [operand | remaining_operands]) do
    acc = acc * operand

    acc <= result &&
      (test_addition(result, acc, remaining_operands) ||
         test_multiplication(result, acc, remaining_operands))
  end

  def run_p(use_example) do
    equations =
      @day
      |> init_day(use_example)
      |> split_lines(:no_trail)
      |> parse_equations()

    equations
    |> Enum.filter(fn {result, operands} ->
      test_addition(result, 0, operands) || test_multiplication(result, 1, operands)
    end)
    |> Enum.reduce(0, fn {result, _}, acc -> acc + result end)
  end

  # Part 2
  def test_addition(result, acc, [last_operand], :with_concat) do
    acc + last_operand == result
  end

  def test_addition(result, acc, [operand | remaining_operands], :with_concat) do
    acc = acc + operand

    (acc <= result &&
       test_addition(result, acc, remaining_operands, :with_concat)) ||
      test_multiplication(result, acc, remaining_operands, :with_concat) ||
      test_concatenation(result, acc, remaining_operands)
  end

  def test_multiplication(result, acc, [last_operand], :with_concat) do
    acc * last_operand == result
  end

  def test_multiplication(result, acc, [operand | remaining_operands], :with_concat) do
    acc = acc * operand

    (acc <= result &&
       test_addition(result, acc, remaining_operands, :with_concat)) ||
      test_multiplication(result, acc, remaining_operands, :with_concat) ||
      test_concatenation(result, acc, remaining_operands)
  end

  def test_concatenation(result, acc, [last_operand]) do
    String.to_integer("#{acc}" <> "#{last_operand}") == result
  end

  def test_concatenation(result, acc, [operand | remaining_operands]) do
    acc = ("#{acc}" <> "#{operand}") |> String.to_integer()

    (acc <= result &&
       test_addition(result, acc, remaining_operands, :with_concat)) ||
      test_multiplication(result, acc, remaining_operands, :with_concat) ||
      test_concatenation(result, acc, remaining_operands)
  end

  def run_q(use_example) do
    equations =
      @day
      |> init_day(use_example)
      |> split_lines(:no_trail)
      |> parse_equations()

    equations
    |> Enum.filter(fn {result, operands} ->
      test_addition(result, 0, operands) || test_multiplication(result, 1, operands) ||
        test_concatenation(result, 0, operands)
    end)
    |> Enum.reduce(0, fn {result, _}, acc -> acc + result end)
  end
end
