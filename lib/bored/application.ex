defmodule Bored.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Bored.Redix.child_spec("redis://localhost:3001"),
      {Plug.Cowboy, scheme: :http, plug: Bored.Router, options: [port: 8080]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
