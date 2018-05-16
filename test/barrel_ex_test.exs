defmodule BarrelExTest do
  use ExUnit.Case
  doctest BarrelEx

  test "greets the world" do
    assert BarrelEx.hello() == :world
  end
end
