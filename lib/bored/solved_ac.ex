defmodule Bored.SolvedAc do
  use HTTPoison.Base

  @spec process_request_url(String.t()) :: String.t()
  def process_request_url(url), do: "https://solved.ac" <> url

  @spec check_404(Floki.html_tree()) :: :ok | :error
  def check_404(doc) do
    if doc
       |> Floki.find("h1")
       |> Floki.text() == "404",
       do: :error,
       else: :ok
  end
end
