defmodule CivilCode.Params do
  @moduledoc """
  A map with keys and values and strings based in from the boundary.

  Params can be passed into an ApplicationService. In a Simple Architecture, params are passed to
  the Entity directly, where as a Rich-Domain Architecture will use a Command to coerce the params
  to Value Objects.
  """

  @type t :: %{String.t() => String.t()}
end
