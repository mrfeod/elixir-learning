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

  def get_result(job_id) do
    receive do
      {:result, ^job_id, result} ->
        result
    after
      100 ->
        raise "Timeout"
    end
  end

  def select_worker do
    workers = MapReduceApp.Supervisor.workers()
    Enum.at(workers, :rand.uniform(length(workers)) - 1)
  end

  def select_and_execute(job) do
    execute(select_worker(), job)
  end

  def reduce(jobs, reducer) do
    Enum.reverse(jobs)
    |> Enum.map(fn job -> select_and_execute(job) end)
    |> Enum.map(fn job_id -> get_result(job_id) end)
    |> Enum.reduce(reducer)
  end
end
