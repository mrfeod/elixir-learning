defmodule MapReduceApp.MapReduce do
  @moduledoc """
  Documentation for `MapReduce`.
  """

  alias MapReduceApp.Worker

  def execute(worker_id, job) do
    {_type, job_id} = Worker.add_job(worker_id, job, 100)
    job_id
  end

  def get_result(worker_id, job_id) do
    {_type, result} = Worker.get_result(worker_id, job_id, 100)
    result
  end

  def reduce(worker_id, jobs, reducer) do
    Enum.reverse(jobs)
    |> Enum.map(fn job -> execute(worker_id, job) end)
    |> Enum.map(fn job_id -> get_result(worker_id, job_id) end)
    |> Enum.reduce(nil, reducer)
  end

  def select_worker do
    workers = MapReduceApp.Supervisor.workers()
    Enum.at(workers, :rand.uniform(length(workers)) - 1)
  end

  def select_and_execute(job) do
    worker_id = select_worker()
    job_id = execute(worker_id, job)
    get_result(worker_id, job_id)
  end
end
