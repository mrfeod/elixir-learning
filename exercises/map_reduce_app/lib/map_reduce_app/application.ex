defmodule MapReduceApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, [keys: :unique, name: Registry.MapReduceApp]},
      MapReduceApp.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    [
      %{
        id: :rootsv,
        start:
          {Supervisor, :start_link,
           [children, [name: MapReduceApp.RootSupervisor, strategy: :rest_for_one]]}
      }
    ]
    |> Supervisor.start_link(strategy: :one_for_all)
  end
end
