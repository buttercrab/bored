defmodule Bored.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "")
  end

  forward("/res", to: Bored.Router.Resource)

  forward("/api/v1", to: Bored.Router.Api.V1)

  match _ do
    send_resp(conn, 404, "")
  end
end
