defmodule RoachFeed.MixProject do
	use Mix.Project

	@version "0.0.7"

	def project do
		[
			app: :roachfeed,
			deps: deps(),
			elixir: "~> 1.10",
			version: @version,
			elixirc_paths: paths(Mix.env),
			description: "CockroachDB ChangeFeed Consumer",
			package: [
				licenses: ["MIT"],
				links: %{
					"git" => "https://github.com/karlseguin/roachfeed"
				},
				maintainers: ["Karl Seguin"],
			],
		]
	end

	defp paths(:test), do: paths(:prod) ++ ["test/support"]
	defp paths(_), do: ["lib"]

	def application do
		[
			extra_applications: [:logger]
		]
	end

	defp deps do
		[
			{:jason, "~>1.2.2", only: :test},
			{:postgrex, "~>0.15.6", only: :test},
			{:ex_doc, "~> 0.22.6", only: :dev, runtime: false},
		]
	end
end
