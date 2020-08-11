defmodule RoachFeed.Tests.FakeConsumer do
	use RoachFeed

	def setup(opts), do: {1, Keyword.fetch!(opts, :test)}

	def query(state) do
		config = [
			for: "table_a"
		]
		{config, state}
	end

	def handle_resolved(msg, {count, pid}) do
		send(pid, {:resolved, msg})
		{count + 1, pid}
	end

	def handle_change(table, key, data, {count, pid}) do
		send(pid, {:change, %{table: table, key: Jason.decode!(key), data: Jason.decode!(data, keys: :atoms)}})
		{count + 1, pid}
	end

	def handle_cast({:test, pid}, {count, _}) do
		{:noreply, {count, pid}}
	end
end
