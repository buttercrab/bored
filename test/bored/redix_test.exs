defmodule RedixTest do
  use ExUnit.Case

  alias Bored.Redix

  @moduletag :capture_log

  doctest Redix

  test "module exists" do
    assert is_list(Redix.module_info())
  end

  setup do
    Supervisor.start_link([Redix.child_spec("redis://localhost:6379")], strategy: :one_for_one)
  end

  test "command" do
    assert Redix.command(["SET", "a", "hello"]) == :ok
    assert Redix.command(["GET", "a"]) == {:ok, "hello"}
    assert Redix.command(["DEL", "a"]) == :ok
  end

  test "pipeline" do
  end
end
