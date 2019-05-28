defmodule CivilCode.Repository do
  @moduledoc """
  A Repository hydrates and persists an Aggregate.

  ## From the Experts

  > This basic set of principles applies to a DDD Repository. Placing an Aggregate (10) instance in
  > its corresponding Repository, and later using that Repository to retrieve the same instance,
  > yields the expected whole object. If you alter a preexisting Aggregate instance that you
  > retrieve from the Repository, its changes will be persisted. If you remove the instance from
  > the Repository, you will be unable to retrieve it from that point forward. [IDDD, p. 401]

  ## Usage

  CivilCode implements persistence-oriented, save-based Repository (12). This is because Ecto
  doesn’t implicitly or explicitly detect and track data changes, which is not unexpected in a
  functional programming environment. A Repository should mimic a collection as much as possible,
  even though this repository is not a collection-based repository, i.e. it appears the collection
  is in-memory.

  A Repository hydrates an aggregate and persists the aggregate using the `save/1` function. See
  `CivilCode.Repository.Behaviour`.

  The Repository is the perfect place to handle unique constraint errors and other issues related
  to collections and persistence.

  Repositories can be adapters for other stores beyond a traditional RDBMS. These may be a key-value
  store or even the file system.

  For more complex queries required for a use case:

  > You might instead use what is called a use case optimal query. This is where you specify a
    complex query against the persistence mechanism, dynamically placing the results into a
    Value Object (6) specifically designed to address the needs of the use case. [IDDD, p. 517]

  Repositories MUST BE used for __Rich-Domain__ and __Event-Driven__ Architectures.

  Both of these architectures require Commands which cast Params to Value Objects, it is the
  invalid Command in the form of a `Ecto.Changeset.t()` that is returned to the client. Although,
  Entity domain actions return `Ecto.Changeset.t()` in a Rich-Domain Architecture they are not returned
  to the client as the data is already validated, therefore an explicit `CivilCode.RepositoryError.t()` must
  be returned.
  """

  alias CivilCode.{Aggregate, Entity, EntityId, Result}

  defmodule Behaviour do
    @moduledoc """
    The behaviour for a repository.
    """

    @type id :: %{__struct__: atom, value: EntityId.t()}

    @doc """
    Generates an ID for an entity.
    """
    @callback next_id() :: id

    @doc """
    Retrieves an aggregate from the Repository.
    """
    @callback get(id) :: Aggregate.t()

    @doc """
    Persists the aggregate in the Repository.
    """
    @callback save(Entity.t() | Ecto.Changeset.t()) :: Result.t(Entity.t())
  end

  defmacro __using__(_) do
    quote do
      alias CivilCode.{Entity, RepositoryError, Result}

      @behaviour Behaviour

      @doc """
      Builds an Entity from a database record.

      Example:

          build(Order, fn ->
            Repo.get!(Record, order_id)
          end)
      """
      def build(module, func) do
        record = func.()

        module
        |> Entity.build(record)
        |> Entity.put_assigns(:record, record)
      end
    end
  end
end
