defmodule Worker do
  @moduledoc """
  Documentation for `Worker`.
  """

  def start() do
    loop(%{})
  end

  defp loop(state) do
    receive do
      message ->
        state = handle_message(message, state)
      loop(state)
    end
  end

  defp handle_message(message, state) do
    case message do
    {:job, job, sender} ->
      job_id = make_ref()
      send(sender, {:job_id, job_id})
      state = Map.put_new(state, job_id, job.())
      state
    {:job_id, job_id, sender} ->
      send(sender, {:result, Map.get(state, job_id, :no_job)})
      state
    _ ->
      state
    end
  end
end
