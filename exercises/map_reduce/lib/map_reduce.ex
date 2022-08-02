defmodule MapReduce do
  @moduledoc """
  Documentation for `MapReduce`.
  """

  @spec create :: pid
  def create() do
    spawn_link(Worker, :start, [])
  end

  def execute(worker, job) do
    monitor = Process.monitor(worker)
    request_id = make_ref()
    send(worker, {:job, request_id, job, self()})

    res = receive do
      {:job_id, ^request_id, job_id} ->
        job_id

      {:DOWN, ^monitor, _, _, _} ->
        :worker_fault
    after
      1_000 -> :worker_fault
    end

    Process.demonitor(monitor)
    res
  end

  def get_result(worker, job_id) do
    monitor = Process.monitor(worker)
    request_id = make_ref()
    send(worker, {:job_id, request_id, job_id, self()})

    res = receive do
      {:result, ^request_id, result} ->
        result

      {:DOWN, ^monitor, _, _, _} ->
        :worker_fault
    after
      1_000 -> :worker_fault
    end

    Process.demonitor(monitor)
    res
  end

  # TODO jobs - list of lambdas
  def reduce(worker, jobs, reducer) do
    reduced =
      Enum.map_reduce(jobs, 0, fn job, acc ->
        result =
          case get_result(worker, job) do
            :worker_fault -> 0
            :no_job -> 0
            value -> value
          end

        {result, reducer.(acc, result)}
      end)

    elem(reduced, 1)
  end
end
