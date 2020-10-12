defmodule MapRewire.MixProject do
  use Mix.Project

  def project do
    [
      app: :map_rewire,
      version: "0.2.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 0.13", only: :dev},
      {:excoveralls, "~> 0.9", only: :test},
      {:exprof, "~> 0.2.0", only: :test},
      {:ex_doc, "~> 0.23.0", only: :dev}
    ]
  end

  defp description do
    """
    Complete syntactic sugar to rekey maps.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "config", "README*", "LICENSE*"],
      licenses: ["The MIT License (MIT)"],
      maintainers: ["Jordan Parker"],
      links: %{"GitHub" => "https://github.com/byjord/MapRewire"}
    ]
  end
end
