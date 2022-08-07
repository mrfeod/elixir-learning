defmodule MapReduceApp.MapReduce do
  @moduledoc """
  Documentation for `MapReduce`.
  """

  alias MapReduceApp.Worker

  @request_timeout 100
  @result_timeout 10_000

  def execute(worker_id, job) do
    {_type, job_id, worker_pid} = Worker.add_job(worker_id, job, @request_timeout)
    {job_id, worker_pid}
  end

  def get_result(worker_id, job_id) do
    {_type, result} = Worker.get_result(worker_id, job_id, @request_timeout)
    result
  end

  def get_result(job_id) do
    receive do
      {:result, ^job_id, result} ->
        result
    after
      @result_timeout ->
        raise "Timeout"
    end
  end

  def select_worker do
    MapReduceApp.WorkerSupervisor.workers() |> Enum.random()
  end

  def select_and_execute(job) do
    execute(select_worker(), job)
  end

  def reduce(jobs, reducer) do
    Enum.reverse(jobs)
    |> Enum.map(fn job ->
      {job_id, _} = select_and_execute(job)
      job_id
    end)
    |> Enum.map(fn job_id -> get_result(job_id) end)
    |> Enum.reduce(reducer)
  end
end
