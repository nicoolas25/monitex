defmodule Monitex.Mixfile do
  use Mix.Project

  def project do
    [app: :monitex,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps(Mix.env)]
  end

  def application do
    [applications: [:logger]]
  end

  #
  # Declare the dependencies for each environment
  #

  defp deps(:prod) do
    [
      { :oauth, github: "tim/erlang-oauth", tag: "v1.5.0" },
      { :jsex, version: "~>2.0.0" },
    ]
  end

  defp deps(:dev) do
    deps(:prod) ++ [
      { :apex, "~>0.3.0" },
    ]
  end

  defp deps(:test) do
    deps(:dev) ++ [
      { :exvcr, github: "nicoolas25/exvcr" },
    ]
  end

  defp deps(_) do
    deps(:prod)
  end
end
