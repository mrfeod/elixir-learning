defmodule Worker do
  @moduledoc """
  Documentation for `Worker`.
  """
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def add_job(worker_id, job, timeout) when is_function(job, 0) do
    GenServer.call(worker_id, {:job, job}, timeout)
  catch
    :exit, _ -> {:fail, nil}
  end

  def get_result(worker_id, job_id, timeout) when is_reference(job_id) do
    GenServer.call(worker_id, {:job_id, job_id}, timeout)
  catch
    :exit, _ -> {:fail, nil}
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
