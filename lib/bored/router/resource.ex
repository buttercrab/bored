defmodule Bored.Router.Resource do
  @moduledoc """
  Resource static serving router
  """
  @moduledoc since: "0.1.0"

  use Plug.Builder

  plug(Plug.Static, at: "/", from: "pub/res")
  plug(:not_found)

  @doc """
  function if not found
  """
  @doc since: "0.1.0"
  def not_found(conn, _) do
    send_resp(conn, 404, "static resource not found")
  end
end
