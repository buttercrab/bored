defmodule ScrapTest do
  use ExUnit.Case

  alias Bored.Scrap

  @moduletag :capture_log

  doctest Scrap

  test "module exists" do
    assert is_list(Scrap.module_info())
  end

  test "check prob_info on problem 1000" do
    assert Scrap.prob_info(1000) == %{id: 1000, title: "A+B", is_eng: false, tier: "Bronze V"}
  end

  test "check prob_info on problem 999 (not exist)" do
    assert Scrap.prob_info(999) == :error
  end

  test "check prob_info on problem 23277 (english problem)" do
    assert Scrap.prob_info(23277).is_eng == true
  end

  test "check prob_info on problem 18826 (not rated)" do
    assert Scrap.prob_info(18826).tier == "Not ratable"
  end

  test "check user_info on buttercrab" do
    assert Scrap.user_info("buttercrab").id == "buttercrab"
  end

  test "check rand_prob on Platinum V to Platinum I" do
    assert is_list(Scrap.rand_prob({"Platinum V", "Platinum I"}))
  end
end
