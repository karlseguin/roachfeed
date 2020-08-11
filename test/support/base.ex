defmodule RoachFeed.Tests.Base do
	use ExUnit.CaseTemplate

	using do
		quote do
			import RoachFeed.Tests.Base
		end
	end
end
