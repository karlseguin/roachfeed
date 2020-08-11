defmodule RoachFeed.Error do
	@moduledoc """
	Represents an error.

	The `source` field is `:cockroachdb` when the error was returned by the server.
	In such cases the `code` field should be the integer code returned (though it
	could be `nil` in the unlikely case that the error couldn't be parsed properly).

	Otherwise the `source` field can be either `:tcp` or `:driver` to indicate a
	tcp-level error or an error arising from this library. In both cases, `code`
	will be nil.

	The `message` field contains a human readable description of the problem. It is
	always present. It's usually a string, except when `source` is `:tcp` it will
	be an atom.

	The `details` field can contain anything, including `nil`.
	"""

	defexception [
		:source,
		:message,
		:details,
		:code,
	]

	@doc """
	Turns an RoachFeed.Error into a binary for display
	"""
	def message(e) do
		:erlang.iolist_to_binary([
			Atom.to_string(e.source), ?\s,
			to_string(e.message),  # can be an atom
			details(e.details)
		])
	end

	defp details(nil), do: []
	defp details(details), do: ["\n\n" | inspect(details)]

	@doc false
	def cockroach({?E, message}), do: cockroach(message)
	def cockroach(message) do
		pg = parse_pg_error(message, [])
		%__MODULE__{
			details: pg,
			code: pg[:code],
			source: :cockroachdb,
			message: pg[:message],
		}
	end

	@doc false
	def driver(message, details \\ nil) do
		%__MODULE__{
			source: :driver,
			message: message,
			details: details,
		}
	end

	@fields %{
		?S => :severity,
		?V => :severity2,
		?C => :code,
		?M => :message,
		?D => :detail,
		?H => :hint,
		?P => :position,
		?p => :internal_position,
		?W => :where,
		?s => :schema,
		?t => :table,
		?c => :column,
		?n => :constraint,
		?F => :file,
		?L => :line,
		?R => :routine,
	}

	defp parse_pg_error(<<0>>, acc), do: acc
	for {field, name} <- @fields do
		defp parse_pg_error(<<unquote(field), rest::binary>>, acc) do
			[value, rest] = :binary.split(rest, <<0>>)
			parse_pg_error(rest, [{unquote(name), value} | acc])
		end
	end

	# if we get an error field with an unknown type prefix, use the type
	# itself as the key
	defp parse_pg_error(<<type, rest::binary>>, acc) do
		[value, rest] = :binary.split(rest, <<0>>)
		parse_pg_error(rest, [{<<type::utf8>>, value} | acc])
	end
end
