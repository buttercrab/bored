defmodule BoredTest do
  use ExUnit.Case
  doctest Bored

  test "greets the world" do
    assert Bored.hello() == :world
  end
end
