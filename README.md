# CockroachdB ChangeFeed Consumer

Consumes a CockroachDB Core ChangeFeed. Doesn't use Postgrex (except for testing). Doesn't open a pool. It open a single (per instance) tcp connection which is optimized for dealing with feed data.

Usage:

In your mix.exs file, add the project dependency:

```
{:roachfeed, "~> 0.0.4"}
```

Next create a module:

```elixir
defmodule MyModule do
	use RoachFeed

	# Optional, this will be the state passed to query/1, handle_resolve/2
	# and handle_change/4
	defp setup(opts) do
		state
	end

	# Called once the connection is estasblished.
	# `for` must be specified (it can be a list of table, or a single table)
	# `with` is an optional keyword list that matches the options that
	#        'experimental changefeed for ...' supports
	#        (Note: it's OK to pass `nil` to the `cursor` key)
	defp query(state) do
		config = [
			for: ["table_1", "table_2"],
			with: [
				resolved: "10s",
				cursor: elem(state, 2)[:resolved]
			]
		]
		{config, state}
	end

	# `msg` is not parsed. You probably want to Jason.decode!/1 it.
	defp handle_resolved(msg, state) do
		IO.inspect(msg)
		state
	end

	# `key` and `data` are not parsed. You may want to Jason.decode/1 them.
	# If `envelope: "key_only` is passed to the `with:` keyword list of
	# `query/1`, then `data` will be nil.
	defp handle_change(table, key, data, state) do
		IO.inspect({table, key, data})
		state
	end
end
```

Start `MyModule` (as a child of a supervisor most likely), passing it the typically connection string value:

```elixir
{MyModule, [port: 26257, hostname: "127.0.0.1", database: "...", username: "...", password: "..."]}
```
