defmodule BarrelEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :barrel_ex,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "barrel_ex_http",
      source_url: "https://gitlab.com/barrel-db/Clients/barrel_ex",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "Barrel-db HTTP API Elixir client"
  end

  defp package do
    name: "barrel_ex_http",
    maintainers: ["Jakub Janarek"],
    licenses: ["MIT License"],
    links: %{"Gitlab" => "https://gitlab.com/barrel-db/Clients/barrel_ex",
    "GitHub" => "https://github.com/jxub/barrel_ex"}
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.1.0"},
      {:jason, "~> 1.0"},
      {:morphix, "~> 0.3.0"},
      {:credo, "~> 0.8", only: [:dev, :test]},
      {:excoveralls, "~> 0.8", only: :test},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
