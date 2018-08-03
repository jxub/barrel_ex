defmodule Barrex.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :barrex,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "barrel_ex",
      source_url: "https://gitlab.com/barrel-db/Clients/barrel_ex"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Barrex.App, []}
    ]
  end

  defp description do
    "Barrel-db Elixir native client"
  end

  defp package do
    [
      name: "barrel_ex",
      files: ["config", "lib", "test", "LICENSE", "mix.exs", "README.md"],
      maintainers: ["Jakub Janarek", "Benoît Chesneau"],
      licenses: ["MIT License"],
      links: %{
        "GitHub" => "https://github.com/jxub/barrel_ex",
        "GitLab" => "https://gitlab.com/barrel-db/Clients/barrel_ex"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:barrel, git: "https://gitlab.com/barrel-db/barrel.git", branch: "store"},
      {:mongodb, ">= 0.0.0", only: :dev},
      {:poolboy, ">= 0.0.0"},
      {:socket, "~> 0.3"},
      {:credo, "~> 0.8", only: [:dev, :test]},
      {:excoveralls, "~> 0.8", only: :test},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
