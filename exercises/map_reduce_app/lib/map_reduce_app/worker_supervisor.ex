defmodule MapReduceApp.WorkerSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def workers do
    :persistent_term.get(:workers)
  end

  defp get_busy_workers do
    case :ets.lookup(:queue, :workers) do
      [] -> []
      data -> {:workers, busy} = data |> List.first; busy
    end
  end

  defp set_busy_workers busy do
    :ets.insert(:queue, {:workers, busy})
  end

  def select_worker do
    busy = get_busy_workers()
    worker = workers() |> Enum.reject(fn worker -> Enum.member?(busy, worker) end) |> Enum.at(0)
    if worker do
      set_busy_workers [worker | busy]
    end
    worker
  end

  def free_worker(worker) do
    busy = get_busy_workers()
    set_busy_workers List.delete(busy, worker)
  end

  @impl true
  def init(:ok) do
    workers =
      for n <- 1..System.schedulers_online() do
        {:via, Registry, {Registry.MapReduceApp, n}}
      end

    :persistent_term.put(:workers, workers)
    :ets.new(:queue, [:set, :public, :named_table])

    children =
      Enum.map(workers, fn id ->
        {_, _, {_, child_id}} = id

        %{
          id: child_id,
          start: {MapReduceApp.Worker, :start_link, [%{name: id}]}
        }
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
