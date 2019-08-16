defmodule CivilCode.DomainService do
  @moduledoc """
  A service in the domain performs a domain-specific task.

  # Usage

  Domain services receive Entities as parameters, generally do not raise exceptions (i.e. returns
  a Result type and may have side effects.

  # Design Constraints

  * Do not confuse a DomainService with `CivilCode.ApplicationService`.
  * DomainServices are part of the domain therefore the name of the service should include the
    Ubiquitous Language.
  * Avoid an Anemic Domain Model by placing all business logic in Domain Services.
  * DomainServices are called from the `CivilCode.ApplicationService` and receive aggregates
    as parameters.

  ## From the Experts

  > Sometimes, it just isn’t a thing. . . . When a significant process or transformation in the
  > domain is not a natural responsibility of an ENTITY or VALUE OBJECT, add an operation to the
  > model as a standalone interface declared as a SERVICE. Define the interface in terms of the
  > language of the model and make sure the operation name is part of the UBIQUITOUS LANGUAGE.
  > Make the SERVICE stateless. [Evans, p. 104, 106]

  > You’ve spoken to domain experts about a domain concept that involves multiple entities, but
  > you’re unsure about which entity “owns” the behavior. It doesn’t appear to belong to any of
  > them, and it seems awkward when you try to force‐fit it onto either of them. This pattern of
  > thinking is a strong indicator of the need for a domain service. [PPPoD p. 390]

  Examples of DomainService may include:

  * Policy: determining if a group of aggregates comply with a business policy
  * Processor: running business logic across multiple aggregates, e.g. `OrderProcessor`
  * Calculation: making a calculation across a number of entities
  """

  defmacro __using__(_) do
    quote do
      alias CivilCode.{EntityId, Result}
    end
  end
end
