defmodule Bored do
  @type prob_id() :: integer()
  @type prob_tier() :: String.t()
  @type prob_title() :: String.t()
  @type prob_info() :: %{id: prob_id(), title: prob_title(), is_eng: boolean(), tier: tier()}

  @type user_id() :: String.t()
  @type user_tier() :: String.t()
  @type user_solved() :: [prob_id()]
  @type user_info() :: %{id: user_id(), solved: user_solved(), tier: user_tier()}

  @type tier_range() :: {prob_tier(), prob_tier()}
  @type problems() :: [prob_id()]
end
