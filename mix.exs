defmodule MapRewire.MixProject do
  use Mix.Project

  @source_url "https://github.com/byjord/MapRewire"
  @version "0.3.0"

  def project do
    [
      app: :map_rewire,
      version: @version,
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      package: package(),
      deps: deps(),
      docs: docs()
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
      {:benchee, "~> 1.0", only: :dev},
      {:excoveralls, "~> 0.9", only: :test},
      {:exprof, "~> 0.2.0", only: :test},
      {:ex_doc, "~> 0.25.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      description: "Complete syntactic sugar to rekey maps.",
      files: ["lib", "mix.exs", "config", "README*", "LICENSE*"],
      licenses: ["MIT"],
      maintainers: ["Jordan Parker"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"],
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
