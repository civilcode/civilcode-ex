defmodule CivilCode.Params do
  @moduledoc """
  A map with keys and values and strings based in from the boundary.

  Params can be passed into an ApplicationService. In a __Simple_Domain__ Architecture, params are passed to
  the Entity directly, where as a __Rich-Domain__ Architecture will use a Command to coerce the params
  to Value Objects.
  """

  @type t :: %{String.t() => String.t()}
end
