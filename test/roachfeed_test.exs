defmodule RoachFeed.Tests do
	use RoachFeed.Tests.Base
	alias RoachFeed.Tests.FakeConsumer

	setup_all do
		{:ok, _} = Postgrex.start_link(name: :testdb, hostname: "localhost", port: 26257, username: "root", database: "roachfeed_test")
		query!("drop table if exists table_a")
		query!("drop table if exists table_b")
		query!("create table table_a (id int primary key, value text)")
		query!("create table table_b (id text primary key, value int)")
		:ok
	end

	test "gets existing changes" do
		query!("insert into table_a (id, value) values ($1, $2), ($3, $4)", [1, "over", 2, "9000!"])
		start_consumer()
		change = forwarded(:change)
		assert change.key == [1]
		assert change.table == "table_a"
		assert change.data ==  %{after: %{id: 1, value: "over"}}

		change = forwarded(:change)
		assert change.key == [2]
		assert change.table == "table_a"
		assert change.data ==  %{after: %{id: 2, value: "9000!"}}
	end

	defp query!(sql, args \\ []) do
		Postgrex.query!(:testdb, sql, args)
	end

	defp start_consumer() do
		opts = [
			test: self(),  # used by our fake consumer in setup to forward messages to this pid (our test)
			port: 26257,
			username: "root",
			hostname: "localhost",
			database: "roachfeed_test"
		]
		{:ok, _} = FakeConsumer.start_link(opts)
	end

	def forwarded(type) do
		receive do
			{^type, msg} -> msg
		after
			100 -> nil
		end
	end

end
