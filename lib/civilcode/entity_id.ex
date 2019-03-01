defmodule CivilCode.EntityId do
  @moduledoc """
  The ID used for an Entity concept in the domain.
  """
  @type t :: binary

  @spec generate() :: t
  def generate, do: UUID.uuid4()
end
