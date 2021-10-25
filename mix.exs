defmodule Bored.MixProject do
  use Mix.Project

  def project do
    [
      app: :bored,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "bored",
      source_url: "https://github.com/buttercrab/bored",
      docs: [
        main: "bored",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.32.0"},
      {:httpoison, "~> 1.8"},
      {:plug_cowboy, "~> 2.0"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:redix, "~> 1.1"},
      {:castore, ">= 0.0.0"}
    ]
  end
end
