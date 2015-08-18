defmodule Raygun.Mixfile do
  use Mix.Project

  def project do
    [app: :raygun,
     version: "0.0.14",
     elixir: "~> 1.0",
     source_url: "https://github.com/cobenian/raygun",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpoison, :plug]]
  end

  def description do
    """
    Send errors in your application to Raygun.

    Raygun captures all your application errors in one place. It can be used as
    a Plug, via Logger and/or programmatically.
    """
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
      {:poison, "~> 1.4.0"},
      {:httpoison, "~> 0.7.2"},
      {:timex, "~> 0.19.2"},
      {:plug, "~> 1.0.0"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.7", only: :dev},
    ]
  end

  defp package do
    [# These are the default files included in the package
     contributors: ["Bryan Weber"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/cobenian/raygun"}]
  end
end
