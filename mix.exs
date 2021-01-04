defmodule GooglePubsubGrpc.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :google_pubsub_grpc,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/vjebelev/google_pubsub_grpc"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :goth]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.7.0"},
      {:goth, "~> 1.2.0"},
      {:grpc, github: "elixir-grpc/grpc"}
    ]
  end
end
