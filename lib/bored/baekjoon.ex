defmodule Bored.Baekjoon do
  use HTTPoison.Base

  @spec process_request_url(String.t()) :: String.t()
  def process_request_url(url), do: "https://www.acmicpc.net" <> url

  @spec check_404(Floki.html_tree()) :: :ok | :error
  def check_404(doc) do
    if doc
       |> Floki.find(".error-v1-title")
       |> Enum.empty?(), do: :ok, else: :error
  end
end
