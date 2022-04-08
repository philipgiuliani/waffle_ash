defmodule Waffle.Ash.MixProject do
  use Mix.Project

  def project do
    [
      app: :waffle_ash,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
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
      {:waffle, "~> 1.0"},
      {:ash, "~> 1.51 and >= 1.5.2"}
    ]
  end
end
