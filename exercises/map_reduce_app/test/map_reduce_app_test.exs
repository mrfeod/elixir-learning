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
    job = MapReduce.execute(worker_id, fn -> :ok end)
    assert is_reference(job)
  end

  test "Get job result", %{:worker => worker_id} do
    job = MapReduce.execute(worker_id, fn -> 1 + 2 end)
    result = MapReduce.get_result(worker_id, job)
    assert result == 3
  end

  test "Get non-existent job result", %{:worker => worker_id} do
    job = make_ref()
    result = MapReduce.get_result(worker_id, job)
    assert result == nil
  end

  test "Reduce results", %{:worker => worker_id} do
    reduced =
      MapReduce.reduce(worker_id, [fn -> 1 + 1 end, fn -> 2 + 2 end, fn -> 3 + 3 end], fn l, r ->
        (l || 0) + (r || 0)
      end)

    assert reduced == 1 + 1 + 2 + 2 + 3 + 3
  end

  test "Reduce strings", %{:worker => worker_id} do
    reduced =
      MapReduce.reduce(worker_id, [fn -> "Hello" end, fn -> " " end, fn -> "World" end], fn l,
                                                                                            r ->
        (l || "") <> (r || "")
      end)

    assert reduced == "Hello World"
  end

  test "Select and execute" do
    result = MapReduce.select_and_execute(fn -> :ok end)
    assert result == :ok
  end
end
