defmodule Bored.Router.Api.V1 do
  @moduledoc """
  Version 1 of api
  """
  @moduledoc since: "0.1.0"

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/problem" do
    send_resp(conn, 200, "{id: #{}}")
  end

  get "/users" do
    send_resp(conn, 200, "")
  end

  get "/user/:user_id" do
    send_resp(conn, 200, "")
  end

  match _ do
    send_resp(conn, 404, "api not exists")
  end
end
