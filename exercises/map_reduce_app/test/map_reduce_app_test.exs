defmodule MapReduceAppTest do
  @moduledoc """
  Documentation for `MapReduceAppTest`.
  """
  use ExUnit.Case

  alias MapReduceApp.MapReduce

  setup do
    {:ok, worker: MapReduce.select_worker()}
  end

  test "Execute the job", %{:worker => worker_id} do
    job = MapReduce.execute(worker_id, fn -> 1 + 2 end)
    result = MapReduce.get_result(job)
    result_state = MapReduce.get_result(worker_id, job)
    assert is_reference(job)
    assert result == 3
    assert result == result_state
  end

  test "Get non-existent job result" do
    job = make_ref()
    assert_raise RuntimeError, "Timeout", fn -> MapReduce.get_result(job) end
  end

  test "Get non-existent job result by worker", %{:worker => worker_id} do
    job = make_ref()
    result = MapReduce.get_result(worker_id, job)
    assert result == nil
  end

  test "Select and execute" do
    job = MapReduce.select_and_execute(fn -> :ok end)
    result = MapReduce.get_result(job)
    assert result == :ok
  end

  test "Reduce results" do
    reduced =
      MapReduce.reduce([fn -> 1 + 1 end, fn -> 2 + 2 end, fn -> 3 + 3 end], fn l, r ->
        (l || 0) + (r || 0)
      end)

    assert reduced == 1 + 1 + 2 + 2 + 3 + 3
  end

  test "Reduce strings" do
    reduced =
      MapReduce.reduce([fn -> "Hello" end, fn -> " " end, fn -> "World" end], fn l, r ->
        (l || "") <> (r || "")
      end)

    assert reduced == "Hello World"
  end

  test "Reduce with timeout" do
    jobs = [
      fn -> 1 + 1 end,
      fn ->
        Process.sleep(101)
        2 + 2
      end,
      fn -> 3 + 3 end
    ]

    assert_raise RuntimeError,
                 "Timeout",
                 fn ->
                   MapReduce.reduce(
                     jobs,
                     fn l, r ->
                       (l || 0) + (r || 0)
                     end
                   )
                 end
  end
end
