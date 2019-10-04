defmodule CivilCode.Specification do
  @moduledoc """
  A simple implementation of a specification to encapsulate the same domain logic and
  repository logic (i.e. SQL). There is no support for combining specifications.

  For more information on the motivation for this pattern, see:

  https://enterprisecraftsmanship.com/2016/02/08/specification-pattern-c-implementation/

  A specification may implement two functions: `satisfied_by?/2` and `to_query/2`. The first
  parameter is a struct containing the data of the specification and the second parameter is
  the struct representing the entity. If no data is required for the specification
  the module can implement a single arity version of these functions,
  i.e. `satisfied_by?/1` and `to_query/1`.

  All callbacks are optional providing some flexibility in the implementation, but this
  interface is highly recommended.

  Example:

      defmodule MyApp.InitializedClientSpecification do
        use CivilCode.Specification

        typedstruct do
          field :current_date, Date.t
        end

        @spec to_query(t) :: Ecto.Query.t()
        def to_query(specification) do
        %{current_date: current_date} = specification
          from client in MyApp.Client, where: client.initialized_on <= ^current_date,
        end

        @spec satisfied_by?(t, MyApp.Client.t) :: boolean
        def satisfied_by?(specification, client) do
          Date.compare(client.initialized_on, reported_on) in [:lt, :eq]
        end
      end
  """

  @type specification :: struct
  @type entity :: struct

  @callback satisfied_by?(entity) :: boolean
  @callback satisfied_by?(specification, entity) :: boolean
  @callback to_query(entity) :: Ecto.Queryable.t()
  @callback to_query(specification, entity) :: Ecto.Queryable.t()

  @optional_callbacks satisfied_by?: 1, satisfied_by?: 2, to_query: 1, to_query: 2

  defmacro __using__(_) do
    quote do
      use TypedStruct
      import Ecto.Query, only: [from: 2]
      @behaviour CivilCode.Specification
    end
  end
end
