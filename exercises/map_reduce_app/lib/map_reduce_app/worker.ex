defmodule MapReduceApp.Worker do
  @moduledoc """
  Documentation for `Worker`.
  """
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, %{}, name: Map.get(args, :name))
  end

  def add_job(worker_id, job, timeout) when is_function(job, 0) do
    GenServer.call(worker_id, {:job, job}, timeout)
  end

  def get_result(worker_id, job_id, timeout) when is_reference(job_id) do
    GenServer.call(worker_id, {:job_id, job_id}, timeout)
  end

  # GenServer Callbacks
  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:job, job}, _from, state) do
    job_id = make_ref()
    new_state = Map.put_new(state, job_id, job.())
    {:reply, {:job_id, job_id}, new_state}
  end

  @impl true
  def handle_call({:job_id, job_id}, _from, state) do
    {:reply, {:result, Map.get(state, job_id, nil)}, state}
  end
end
