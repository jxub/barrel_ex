defmodule BarrexTest do
  use ExUnit.Case
  doctest Barrex

  test "greets the world" do
    assert Barrex.hello() == :world
  end
end
