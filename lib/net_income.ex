defmodule Dez.Scraper.NetIncome do

  @trimesters 40

  def fetch(ticker) do
    url = "https://ycharts.com/companies/#{ticker}/net_income"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_quarterly_incomes(body)
        |> average_incomes
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  def parse_quarterly_incomes(body) do
    Floki.find(body, ".histDataTable td")
    |> Enum.with_index
    |> Enum.map(fn({entry, index}) -> parse_quarterly_income({entry, index}) end)
    |> Enum.with_index
    |> Enum.filter(fn({_entry, index}) -> rem(index, 2) != 0 end)
    |> Enum.map(fn({entry, _index}) -> entry end)
    |> Enum.take(@trimesters)
  end

  def average_incomes(incomes) do
    teste = Enum.reduce(incomes, &(&1+&2)) / length(incomes)

    IO.inspect(teste)
  end

  def parse_quarterly_income({entry, index}) when rem(index, 2) == 0 do
    date_array =
      Floki.text(entry)
      |> String.split([" "])

    month_name = Enum.at(date_array, 0)
    month = get_month_number(month_name)

    day = String.replace(Enum.at(date_array, 1), ",", "")
    year = Enum.at(date_array, 2)

    "#{year}-#{month}-#{day}"
  end

  def parse_quarterly_income({entry, _}) do
    Floki.text(entry)
    |> String.strip
    |> Float.parse
    |> calculate_income
  end

  def get_month_number(month_name) do
    months = %{
      "Jan." => "01",
      "Feb." => "02",
      "March" => "03",
      "April" => "04",
      "May" => "05",
      "June" => "06",
      "July" => "07",
      "Aug." => "08",
      "Sept." => "09",
      "Oct." => "10",
      "Nov." => "11",
      "Dec." => "12"
    }

    months[month_name]
  end

  def calculate_income({value, "B"}) do
    value * 1_000_000_000
  end

  def calculate_income({value, "M"}) do
    value * 1_000_000
  end

  def calculate_income({value, "K"}) do
    value * 1_000
  end

  def calculate_income(_) do
    :error
  end
end