defmodule MapReduceApp.ReduceSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    Supervisor.init([], strategy: :one_for_one)
  end
end
