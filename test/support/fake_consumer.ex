defmodule RoachFeed.Tests.FakeConsumer do
	use RoachFeed

	defp setup(opts), do: {1, Keyword.fetch!(opts, :test), opts}

	defp query(state) do
		config = [
			for: "table_a",
			with: [
				resolved: "1s",
				cursor: elem(state, 2)[:resolved]
			]
		]
		{config, state}
	end

	defp handle_resolved(msg, {count, pid, opts}) do
		send(pid, {:resolved, Jason.decode!(msg, keys: :atoms)})
		{count + 1, pid, opts}
	end

	defp handle_change(table, key, data, {count, pid, opts}) do
		send(pid, {:change, %{table: table, key: Jason.decode!(key), data: Jason.decode!(data, keys: :atoms)}})
		{count + 1, pid, opts}
	end

	def handle_cast({:test, pid}, {count, _, opts}) do
		{:noreply, {count, pid, opts}}
	end
end
