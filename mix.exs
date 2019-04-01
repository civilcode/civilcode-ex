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
      deps: deps()
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
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false},

      # Runtime
      {:currying, "~> 1.0.3"},
      {:ecto, "~> 3.0.8"},
      {:typed_struct, "~> 0.1.1", runtime: false},
      {:uuid, "~> 1.1.8"}
    ]
  end
end
