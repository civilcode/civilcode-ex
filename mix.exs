defmodule CivilCode.MixProject do
  use Mix.Project

  def project do
    [
      app: :civilcode,
      version: "0.0.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
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
      {:currying, "~> 1.0.3"},
      {:ecto, "~> 2.1"},
      {:typed_struct, "~> 0.1.1", runtime: false},
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
