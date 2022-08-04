defmodule Worker do
  @moduledoc """
  Documentation for `Worker`.
  """
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def add_job(pid, job, timeout) when is_pid(pid) and is_function(job, 0) do
    GenServer.call(pid, {:job, job}, timeout)
  end

  def get_result(pid, job_id, timeout) when is_pid(pid) and is_reference(job_id) do
    GenServer.call(pid, {:job_id, job_id}, timeout)
  end

  # GenServer Callbacks
  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(request, _from, state) do
    case request do
      {:job, job} ->
        job_id = make_ref()
        new_state = Map.put_new(state, job_id, job.())
        {:reply, {:job_id, job_id}, new_state}

      {:job_id, job_id} ->
        {:reply, {:result, Map.get(state, job_id, nil)}, state}
    end
  end
end
