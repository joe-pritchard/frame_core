defmodule FrameCore.MixProject do
  use Mix.Project

  def project do
    [
      app: :frame_core,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: :covertool]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      env: [BACKEND_URL: "https://example.com"],
      extra_applications: [:logger]
    ] ++ mod_spec()
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:uuid, "~> 1.1"},
      {:req, "~> 0.5"},
      {:mox, "~> 1.0", only: :test},
      {:covertool, "~> 2.0", only: :test},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp mod_spec do
    if Mix.env() == :test, do: [], else: [mod: {FrameCore, []}]
  end
end
