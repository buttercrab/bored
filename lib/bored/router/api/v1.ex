defmodule Bored.Router.Api.V1 do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/problem" do
    send_resp(conn, 200, "")
  end

  get "/user/:user_id" do
    send_resp(conn, 200, "")
  end
end
