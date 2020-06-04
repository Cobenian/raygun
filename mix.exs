defmodule Raygun.Mixfile do
  use Mix.Project

  def project do
    [
      app: :raygun,
      version: "0.3.2",
      elixir: "~> 1.3",
      source_url: "https://github.com/cobenian/raygun",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpoison, :plug, :poison]]
  end

  defp description do
    """
    Send errors in your application to Raygun.

    Raygun captures all your application errors in one place. It can be used as
    a Plug, via Logger and/or programmatically.
    """
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:poison, "~> 3.0 or ~> 2.0 or ~> 1.0"},
      {:httpoison, "~> 0.8 or ~> 1.0"},
      {:plug, "~> 1.1"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:meck, "~> 0.8", only: :test},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      maintainers: ["Bryan Weber"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/cobenian/raygun"}
    ]
  end
end
