defmodule MapReduce do
  @moduledoc """
  Documentation for `MapReduce`.
  """

  @spec create :: pid
  def create do
    {:ok, pid} = Worker.start_link()
    pid
  end

  def execute(worker, job) do
    {_type, job_id} = Worker.add_job(worker, job, 100)
    job_id
  end

  def get_result(worker, job_id) do
    {_type, result} = Worker.get_result(worker, job_id, 100)
    result
  end

  def reduce(worker, jobs, reducer) do
    reduced =
      Enum.map_reduce(jobs, nil, fn job, acc ->
        result = get_result(worker, execute(worker, job))
        {result, reducer.(acc, result)}
      end)

    elem(reduced, 1)
  end
end
