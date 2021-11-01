defmodule Bored.Router.Api.V1 do
  @moduledoc """
  Version 1 of api
  """
  @moduledoc since: "0.1.0"

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/problem" do
    send_resp(conn, 200, Poison.encode!(%{prob_id: Bored.State.curr_prob()}))
  end

  get "/users" do
    send_resp(conn, 200, Poison.encode!(Bored.State.user_list()))
  end

  get "/tier" do
    {low, high} = Bored.State.get_tier()
    send_resp(conn, 200, Poison.encode!(%{low: low, high: high}))
  end

  match _ do
    send_resp(conn, 404, "api not exists")
  end
end
