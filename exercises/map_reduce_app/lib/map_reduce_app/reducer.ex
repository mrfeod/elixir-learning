defmodule MapReduceApp.Reducer do
  @moduledoc """
  Documentation for `Reducer`.
  """

  use GenServer

  alias MapReduceApp.MapReduce

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  @spec create(any(), function()) :: Supervisor.on_start_child()
  def create(acc, reducer) do
    Supervisor.start_child(MapReduceApp.ReduceSupervisor, %{
      id: make_ref(),
      start: {__MODULE__, :start_link, [%{acc: acc, reducer: reducer, job_ids: %{}}]}
    })
  end

  def map(pid, job) when is_pid(pid) and is_function(job) do
    GenServer.call(pid, {:job, job})
  end

  def result(pid) when is_pid(pid) do
    GenServer.call(pid, {:reduce})
  end

  @impl true
  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  @impl true
  def handle_call({:job, job}, from, state) do
    {job_id, worker_pid} = MapReduce.select_and_execute(job)
    Process.link(worker_pid)
    new_state = Map.put(state, :job_ids, Map.put(state.job_ids, job_id, {from, worker_pid}))
    {:reply, {:job_id, job_id}, new_state}
  end

  @impl true
  def handle_call({:reduce}, _from, state) do
    {:reply, {:result, state.acc}, state}
  end

  @impl true
  def handle_info({:result, job_id, result}, state) do
    {{from, worker_pid}, new_job_ids} = Map.pop(state.job_ids, job_id)
    Process.unlink(worker_pid)
    GenServer.reply(from, {:done, job_id})
    new_acc = state.reducer.(state.acc, result)
    {:noreply, Map.merge(state, %{acc: new_acc, job_ids: new_job_ids})}
  end

  @impl true
  def handle_info({:EXIT, pid, _reason}, state) do
    jobs =
      Map.filter(state.job_ids, fn
        {_, {_, ^pid}} ->
          true

        _ ->
          false
      end)

    new_state =
      case Map.keys(jobs) do
        [] ->
          state

        job_ids ->
          Process.unlink(pid)
          {failed_job_ids, new_job_ids} = Map.split(state.job_ids, job_ids)

          _ =
            Enum.map(failed_job_ids, fn
              {job_id, {from, ^pid}} ->
                GenServer.reply(from, {:fail, job_id})
            end)

          Map.put(state, :job_ids, new_job_ids)
      end

    {:noreply, new_state}
  end
end
