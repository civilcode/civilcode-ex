defmodule CivilCode.MixProject do
  use Mix.Project

  def project do
    [
      app: :civilcode,
      version: "0.0.0",
      build_path: "_build",
      config_path: "config/config.exs",
      deps_path: "deps",
      lockfile: "mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "readme",
        extras: ["README.md"],
        groups_for_modules: [
          "Adapters for Ports": [
            CivilCode.Repository,
            CivilCode.Repository.Behaviour,
            CivilCode.RepositoryError
          ],
          Application: [
            CivilCode.ApplicationService,
            CivilCode.Command,
            CivilCode.Params,
            CivilCode.ProcessManager,
            CivilCode.QueryResult,
            CivilCode.QueryService
          ],
          Data: [
            CivilCode.Record
          ],
          "Domain Model": [
            CivilCode.AggregateRoot,
            CivilCode.BusinessRuleViolation,
            CivilCode.Entity,
            CivilCode.EntityId,
            CivilCode.DomainEvent,
            CivilCode.DomainService,
            CivilCode.ValueObject
          ],
          Types: [
            CivilCode.Maybe,
            CivilCode.Result,
            CivilCode.ResultList
          ]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # Development
      {:dialyxir, "~> 1.0.0-rc.4", only: :dev, runtime: false},
      {:ex_doc, "~> 0.20.2", only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false},

      # Runtime
      {:currying, "~> 1.0.3"},
      {:ecto, "~> 3.0.8"},
      {:jason, "~> 1.0"},
      {:typed_struct, "~> 0.1.1", runtime: false},
      {:elixir_uuid, "~> 1.2.0"}
    ]
  end
end
