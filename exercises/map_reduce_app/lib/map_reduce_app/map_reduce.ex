defmodule MapReduceApp.MapReduce do
  @moduledoc """
  Documentation for `MapReduce`.
  """

  alias MapReduceApp.Worker, as: Worker

  def execute(worker_id, job) do
    {_type, job_id} = Worker.add_job(worker_id, job, 100)
    job_id
  end

  def get_result(worker_id, job_id) do
    {_type, result} = Worker.get_result(worker_id, job_id, 100)
    result
  end

  def reduce(worker_id, jobs, reducer) do
    reduced =
      Enum.map_reduce(jobs, nil, fn job, acc ->
        result = get_result(worker_id, execute(worker_id, job))
        {result, reducer.(acc, result)}
      end)

    elem(reduced, 1)
  end
end
