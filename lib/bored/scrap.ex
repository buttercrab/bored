defmodule Bored.Scrap do
  @moduledoc """
  Provides scraping function to get information.
  """
  @moduledoc since: "0.1.0"

  @doc """
  Gets problem information from Baekjoon & SolvedAc.

  ## Example

      iex> Bored.Scrap.prob_info(1000)
      %{id: 1000, title: "A+B", is_eng: false, tier: "Bronze V"}

  """
  @doc since: "0.1.0"
  @spec prob_info(prob_id :: integer()) ::
          %{id: integer(), title: String.t(), is_eng: true | false, tier: String.t()}
          | {:error, HTTPoison.Error.t()}
          | {:error, String.t()}
          | :error
  def prob_info(prob_id) do
    with {:ok, html} <- Bored.Baekjoon.get("/problem/#{prob_id}"),
         {:ok, doc} <- Floki.parse_document(html.body),
         :ok <- Bored.Baekjoon.check_404(doc),
         title <-
           doc
           |> Floki.find("#problem_title")
           |> Floki.text(),
         desc <-
           doc
           |> Floki.find("#problem_description")
           |> Floki.text()
           |> String.graphemes(),
         is_eng <-
           desc
           |> Enum.reduce(0, fn x, acc -> if x =~ ~r/[a-zA-Z]/, do: acc + 1, else: acc end)
           |> (&(&1 * 2 > length(desc))).(),
         {:ok, html} <- Bored.SolvedAc.get("/search?query=id%3A#{prob_id}"),
         {:ok, doc} <- Floki.parse_document(html.body),
         :ok <- Bored.SolvedAc.check_404(doc),
         tier <-
           doc
           |> Floki.find("img")
           |> List.last()
           |> Floki.attribute("alt")
           |> List.first() do
      %{id: prob_id, title: title, is_eng: is_eng, tier: tier}
    end
  end

  @doc """
  Gets user information from Baekjoon & SolvedAc.
  """
  @doc since: "0.1.0"
  @spec user_info(user_id :: String.t()) ::
          %{id: String.t(), solved: [integer()], tier: String.t()}
          | {:error, HTTPoison.Error.t()}
          | {:error, String.t()}
          | :error
  def user_info(user_id) do
    with {:ok, html} <- Bored.Baekjoon.get("/user/#{user_id}"),
         {:ok, doc} <- Floki.parse_document(html.body),
         :ok <- Bored.Baekjoon.check_404(doc),
         solved <-
           doc
           |> Floki.find(".panel-body")
           |> List.first()
           |> Floki.children()
           |> Enum.map(&Floki.text(&1)),
         {:ok, html} <- Bored.SolvedAc.get("/profile/#{user_id}"),
         {:ok, doc} <- Floki.parse_document(html.body),
         :ok <- Bored.SolvedAc.check_404(doc),
         tier <-
           doc
           |> Floki.find("#__next > div:nth-child(4) > div > div:nth-child(1) > div:nth-child(2)")
           |> Floki.text(sep: ", ") do
      %{id: user_id, solved: solved, tier: tier}
    end
  end

  defp tier_shortname(tier) do
    [front | back] = String.split(tier)

    front =
      front
      |> String.downcase()
      |> String.at(0)

    back =
      case back do
        ["I"] -> "1"
        ["II"] -> "2"
        ["III"] -> "3"
        ["IV"] -> "4"
        ["V"] -> "5"
        _ -> ""
      end

    front <> back
  end

  @doc """
  Generates random problem in given tier range from SolvedAc.
  """
  @doc since: "0.1.0"
  @spec rand_prob(tier :: {String.t(), String.t()}) ::
          [integer()]
          | {:error, HTTPoison.Error.t()}
          | {:error, String.t()}
          | :error
  def rand_prob(tier) do
    with {lo, hi} <- tier,
         {lo, hi} <- {tier_shortname(lo), tier_shortname(hi)},
         {:ok, html} <- Bored.SolvedAc.get("/search?query=tier%3A#{lo}..#{hi}&sort=random"),
         {:ok, doc} <- Floki.parse_document(html.body),
         :ok <- Bored.SolvedAc.check_404(doc) do
      doc
      |> Floki.find("div.sticky-table > div")
      |> List.first()
      |> Floki.children()
      |> Enum.drop(1)
      |> Enum.map(fn x ->
        x
        |> Floki.find("div:nth-child(1) > span > a > span")
        |> Floki.text()
        |> String.to_integer()
      end)
    end
  end
end
