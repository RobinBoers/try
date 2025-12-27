defmodule Try.MixProject do
  use Mix.Project

  @documentation "https://hexdocs.pm/try"
  @git_repository "https://git.dupunkto.org/~axcelott/try"

  def project do
    [
      app: :try,
      version: "0.1.1",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      source_url: @git_repository,
      homepage_url: @documentation,
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  defp description do
    "Black-magic fuckery that implements the `return` and `try` keywords in Elixir."
  end

  defp package do
    [
      licenses: ["Unlicense"],
      links: %{"Sources" => @git_repository}
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "Try",
      api_reference: false,
      authors: ["Robijntje"],
      formatters: ["html"]
    ]
  end
end
