defmodule FrameCoreTest do
  use ExUnit.Case
  doctest FrameCore

  test "greets the world" do
    assert FrameCore.hello() == :world
  end
end
