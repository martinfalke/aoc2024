defmodule Aoc2024 do
  @moduledoc """
  Documentation for Aoc2024.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Aoc2024.hello()
      :world

  """
  def hello do
    :world
  end

  def run_day(day, part \\ :p) do
    module_name = String.to_existing_atom("Elixir.Day#{day}")
    IO.puts("Import successful of day #{day}..\n")
    IO.puts("Day: #{day}, Part: #{part}\n")
    apply(module_name, String.to_atom("run_#{part}"), [])
  end
end
