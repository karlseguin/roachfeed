defmodule RoachFeed.Tests.FakeConsumer do
	use RoachFeed

	defp setup(opts) do
		state = {1, Keyword.fetch!(opts, :test), opts}
		{state, opts}
	end

	defp query({count, pid, opts} = _state) do
		change_feed = [
			for: "table_a",
			with: [
				resolved: "1s",
				cursor: opts[:resolved]
			]
		]
		state = {count, pid} # we don't need opts anymore
		{state, change_feed}
	end

	defp handle_resolved(msg, {count, pid}) do
		send(pid, {:resolved, Jason.decode!(msg, keys: :atoms)})
		{count + 1, pid}
	end

	defp handle_change(table, key, data, {count, pid}) do
		send(pid, {:change, %{table: table, key: Jason.decode!(key), data: Jason.decode!(data, keys: :atoms)}})
		{count + 1, pid}
	end

	def handle_cast({:test, pid}, {count, _}) do
		{:noreply, {count, pid}}
	end
end
