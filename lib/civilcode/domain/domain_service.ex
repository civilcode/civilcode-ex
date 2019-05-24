defmodule CivilCode.DomainService do
  @moduledoc """
  A service in the domain performs a domain-specific task.

  > Sometimes, it just isn’t a thing. . . . When a significant process or transformation in the
  > domain is not a natural responsibility of an ENTITY or VALUE OBJECT, add an operation to the
  > model as a standalone interface declared as a SERVICE. Define the interface in terms of the
  > language of the model and make sure the operation name is part of the UBIQUITOUS LANGUAGE.
  > Make the SERVICE stateless. [Evans, pp. 104, 106]

  # Usage

  Domain services receive Entities as parameters, generally do not raise exceptions (i.e. returns
  a Result type and may have side effects.
  """

  defmacro __using__(_) do
  end
end
