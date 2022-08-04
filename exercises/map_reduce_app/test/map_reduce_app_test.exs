defmodule MapReduceAppTest do
  use ExUnit.Case
  doctest MapReduceApp

  test "greets the world" do
    assert MapReduceApp.hello() == :world
  end
end
