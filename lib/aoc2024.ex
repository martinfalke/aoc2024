defmodule Aoc2024 do
  @moduledoc """
  Documentation for Aoc2024.
  """

  @doc """
  Run day d, part y in iex.

  ## Examples

      iex> Aoc2024.run_day(1, :p, :example)
      11

  """
  def run_day(day, part \\ :p, example \\ nil) do
    module_name = String.to_existing_atom("Elixir.Day#{day}")
    IO.puts("Import successful of day #{day}..\n")
    IO.puts("Day: #{day}, Part: #{part}\n")
    apply(module_name, String.to_atom("run_#{part}"), [example])
  end

  # Aliases to run part 1 of given day
  def p(day) do
    run_day(day, :p)
  end
  def px(day) do
    run_day(day, :p, :example)
  end

  # Aliases to run part 2 of given day
  def q(day) do
    run_day(day, :q)
  end
  def qx(day) do
    run_day(day, :q, :example)
  end
end
