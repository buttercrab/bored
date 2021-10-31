defmodule Bored.Scrap.SolvedAc do
  @moduledoc """
  `https://solved.ac` HTTPoison base module.
  """
  @moduledoc since: "0.1.0"

  use HTTPoison.Base

  @doc """
  Adds domain of the url.

  ## Examples

      iex> Bored.SolvedAc.process_request_url("/hello")
      "https://solved.ac/hello"
  """
  @doc since: "0.1.0"
  @spec process_request_url(url :: String.t()) :: String.t()
  def process_request_url(url), do: "https://solved.ac" <> url

  @doc """
  Checks if the html tree is 404 page of the domain.
  """
  @doc since: "0.1.0"
  @spec check_404(doc :: Floki.html_tree()) :: :ok | :error
  def check_404(doc) do
    if doc
       |> Floki.find("h1")
       |> Floki.text() == "404",
       do: :error,
       else: :ok
  end
end
