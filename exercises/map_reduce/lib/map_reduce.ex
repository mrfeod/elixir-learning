defmodule MapReduce do
  @moduledoc """
  Documentation for `MapReduce`.
  """

  @spec create :: pid
  def create() do
    spawn_link(Worker, :start, [])
  end

  def execute(worker, job) do
    ref = Process.monitor(worker)
    send(worker, {:job, job, self()})
    receive do
      {:job_id, job_id} ->
        job_id
      message when is_tuple(message) ->
        if elem(message, 0) == :DOWN and elem(message, 1) == ref do
          :worker_fault
        end
      after
        1_000 -> :worker_fault
    end
  end

  def get_result(worker, job_id) do
    ref = Process.monitor(worker)
    send(worker, {:job_id, job_id, self()})
    receive do
      {:result, result} ->
        result
      message when is_tuple(message) ->
        if elem(message, 0) == :DOWN and elem(message, 1) == ref do
          :worker_fault
        end
      after
        1_000 -> :worker_fault
    end
  end

  def reduce(worker, jobs, reducer) do
    reduced = Enum.map_reduce(jobs, 0, fn job, acc ->
      result = case get_result(worker, job) do
      :worker_fault -> 0
      :no_job -> 0
      value -> value
      end
      {result, reducer.(acc, result)}
    end)
    elem(reduced, 1)
  end

end
