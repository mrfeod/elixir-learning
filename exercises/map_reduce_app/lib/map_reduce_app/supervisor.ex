defmodule MapReduceApp.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def workers do
    for n <- 1..System.schedulers_online() do
      {:via, Registry, {Registry.MapReduceApp, String.to_atom("worker_#{n}")}}
    end
  end

  @impl true
  def init(:ok) do
    children =
      Enum.map(workers(), fn id ->
        {_, _, {_, child_id}} = id

        %{
          id: child_id,
          start: {MapReduceApp.Worker, :start_link, [%{name: id}]}
        }
      end)

    Supervisor.init(children, strategy: :one_for_all)
  end
end
