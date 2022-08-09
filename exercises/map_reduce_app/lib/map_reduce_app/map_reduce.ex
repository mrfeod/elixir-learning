defmodule MapReduceApp.MapReduce do
  @moduledoc """
  Documentation for `MapReduce`.
  """

  alias MapReduceApp.Worker

  @request_timeout 100
  @result_timeout 1_000

  def execute(worker_id, job) do
    {_type, job_id, worker_pid} = Worker.add_job(worker_id, job, @request_timeout)
    {job_id, worker_pid, worker_id}
  end

  def get_result({job_id, worker_id}) do
    receive do
      {:result, ^job_id, result} ->
        MapReduceApp.WorkerSupervisor.free_worker(worker_id)
        result
    after
      @result_timeout ->
        MapReduceApp.WorkerSupervisor.free_worker(worker_id)
        raise "Timeout"
    end
  end

  def select_and_execute(job) do
    case MapReduceApp.WorkerSupervisor.select_worker() do
      nil -> {nil, nil}
      worker_id -> execute(worker_id, job)
    end
  end

  def reduce(jobs, reducer) do
    Enum.reverse(jobs)
    |> Enum.map(fn job ->
      {job_id, _worker_pid, worker_id} = select_and_execute(job)
      {job_id, worker_id}
    end)
    |> Enum.map(fn {job_id, worker_id} ->
      get_result({job_id, worker_id})
    end)
    |> Enum.reduce(reducer)
  end
end
