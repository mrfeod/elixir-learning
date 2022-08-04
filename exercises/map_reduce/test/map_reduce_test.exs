defmodule MapReduceTest do
  @moduledoc """
  Documentation for `MapReduceTest`.
  """
  use ExUnit.Case
  doctest MapReduce

  test "Create a worker" do
    worker = MapReduce.create()
    assert is_pid(worker)
  end

  test "Execute the job" do
    worker = MapReduce.create()
    job = MapReduce.execute(worker, fn -> :ok end)
    assert is_reference(job)
  end

  @tag :skip
  test "Execute the job on non-existent worker" do
    not_worker = :c.pid(0, 123, 123)
    job = MapReduce.execute(not_worker, fn -> :ok end)
    assert job == nil
  end

  test "Get job result" do
    worker = MapReduce.create()
    job = MapReduce.execute(worker, fn -> 1 + 2 end)
    result = MapReduce.get_result(worker, job)
    assert result == 3
  end

  @tag :skip
  test "Get busy job result" do
    worker = MapReduce.create()
    job = MapReduce.execute(worker, fn -> :timer.sleep(1001) end)
    result = MapReduce.get_result(worker, job)
    assert job == nil
    assert result == nil
  end

  test "Get non-existent job result" do
    worker = MapReduce.create()
    job = make_ref()
    result = MapReduce.get_result(worker, job)
    assert result == nil
  end

  test "Reduce results" do
    worker = MapReduce.create()

    reduced =
      MapReduce.reduce(worker, [fn -> 1 + 1 end, fn -> 2 + 2 end, fn -> 3 + 3 end], fn l, r ->
        (l || 0) + (r || 0)
      end)

    assert reduced == 1 + 1 + 2 + 2 + 3 + 3
  end

  test "Reduce strings" do
    worker = MapReduce.create()

    reduced =
      MapReduce.reduce(worker, [fn -> "Hello" end, fn -> " " end, fn -> "World" end], fn l, r -> (l || "") <> (r || "") end)

    assert reduced == "Hello World"
  end
end
