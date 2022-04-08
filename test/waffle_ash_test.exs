defmodule Waffle.AshTest do
  use ExUnit.Case
  doctest Waffle.Ash

  test "greets the world" do
    assert Waffle.Ash.hello() == :world
  end
end
