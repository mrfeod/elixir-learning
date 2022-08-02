defmodule MapReduceTest do
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

  test "Execute the job on non-existent worker" do
    not_worker = :c.pid(0, 123, 123)
    job = MapReduce.execute(not_worker, fn -> :ok end)
    assert job == :worker_fault
  end

  test "Get job result" do
    worker = MapReduce.create()
    job = MapReduce.execute(worker, fn -> 1 + 2 end)
    result = MapReduce.get_result(worker, job)
    assert result == 3
  end

  test "Get busy job result" do
    worker = MapReduce.create()
    job = MapReduce.execute(worker, fn -> :timer.sleep(1001) end)
    result = MapReduce.get_result(worker, job)
    assert result == :worker_fault
  end

  test "Get non-existent job result" do
    worker = MapReduce.create()
    job = make_ref()
    result = MapReduce.get_result(worker, job)
    assert result == :no_job
  end

  test "Reduce results" do
    worker = MapReduce.create()
    jobs = []
    jobs = [MapReduce.execute(worker, fn -> 1 + 1 end) | jobs]
    jobs = [MapReduce.execute(worker, fn -> 2 + 2 end) | jobs]
    jobs = [MapReduce.execute(worker, fn -> 3 + 3 end) | jobs]
    reduced = MapReduce.reduce(worker, jobs, fn l, r -> l + r end)
    assert reduced == 1 + 1 + 2 + 2 + 3 + 3
  end
end
