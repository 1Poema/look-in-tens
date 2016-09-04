defmodule Dez.NumberHelper do
  def parse(value) do
    case value do
      "N/A" ->
        nil

      _ ->
        value
          |> String.strip
          |> Float.parse
          |> multiply
    end
  end

  def multiply({value, "B"}) do
    value * 1_000_000_000
  end

  def multiply({value, "M"}) do
    value * 1_000_000
  end

  def multiply({value, "K"}) do
    value * 1_000
  end

  def multiply(_) do
    :error
  end
end
