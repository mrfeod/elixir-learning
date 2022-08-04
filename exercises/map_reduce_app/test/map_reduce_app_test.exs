defmodule MapReduceAppTest do
  @moduledoc """
  Documentation for `MapReduceAppTest`.
  """
  use ExUnit.Case

  alias MapReduceApp.MapReduce

  test "Execute the job" do
    job = MapReduce.execute(Worker, fn -> :ok end)
    assert is_reference(job)
  end

  test "Get job result" do
    job = MapReduce.execute(Worker, fn -> 1 + 2 end)
    result = MapReduce.get_result(Worker, job)
    assert result == 3
  end

  test "Get non-existent job result" do
    job = make_ref()
    result = MapReduce.get_result(Worker, job)
    assert result == nil
  end

  test "Reduce results" do
    reduced =
      MapReduce.reduce(Worker, [fn -> 1 + 1 end, fn -> 2 + 2 end, fn -> 3 + 3 end], fn l, r ->
        (l || 0) + (r || 0)
      end)

    assert reduced == 1 + 1 + 2 + 2 + 3 + 3
  end

  test "Reduce strings" do
    reduced =
      MapReduce.reduce(Worker, [fn -> "Hello" end, fn -> " " end, fn -> "World" end], fn l, r ->
        (l || "") <> (r || "")
      end)

    assert reduced == "Hello World"
  end
end
