defmodule RoachFeed.MixProject do
	use Mix.Project

	@version "0.0.1"

	def project do
		[
			app: :roach_feed,
			deps: deps(),
			elixir: "~> 1.10",
			version: @version,
			elixirc_paths: paths(Mix.env),
			description: "MonetDB driver",
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
			{:ex_doc, "~> 0.21.2", only: :dev, runtime: false},
		]
	end
end
