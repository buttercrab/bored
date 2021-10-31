defmodule Bored.Application do
  @moduledoc """
  Application of Bored
  """
  @moduledoc since: "0.1.0"

  use Application

  @doc """
  Start function
  """
  @doc since: "0.1.0"
  @impl true
  def start(_type, _args) do
    children = [
      Bored.State,
      Bored.Redix.child_spec("redis://localhost:3001"),
      {Plug.Cowboy, scheme: :http, plug: Bored.Router, options: [port: 8080]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
