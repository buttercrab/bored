defmodule Bored.Scrap.Baekjoon do
  @moduledoc """
  `https://www.acmicpc.net` HTTPoison base module.
  """
  @moduledoc since: "0.1.0"

  use HTTPoison.Base

  @doc """
  Adds domain of the url.

  ## Examples

      iex> Bored.Baekjoon.process_request_url("/hello")
      "https://www.acmicpc.net/hello"
  """
  @doc since: "0.1.0"
  @spec process_request_url(url :: String.t()) :: String.t()
  def process_request_url(url), do: "https://www.acmicpc.net" <> url

  @doc """
  Checks if the html tree is 404 page of the domain.
  """
  @doc since: "0.1.0"
  @spec check_404(doc :: Floki.html_tree()) :: :ok | :error
  def check_404(doc) do
    if doc
       |> Floki.find(".error-v1-title")
       |> Enum.empty?(),
       do: :ok,
       else: :error
  end
end
