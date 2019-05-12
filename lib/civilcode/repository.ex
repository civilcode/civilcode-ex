defmodule CivilCode.Repository do
  @moduledoc """

  > This basic set of principles applies to a DDD Repository. Placing an Aggregate (10) instance in
  > its corresponding Repository, and later using that Repository to retrieve the same instance,
  > yields the expected whole object. If you alter a preexisting Aggregate instance that you
  > retrieve from the Repository, its changes will be persisted. If you remove the instance from
  > the Repository, you will be unable to retrieve it from that point forward. [Vernon, p. 401]

  CivilCode implements persistence-oriented, save-based Repository (12). This is because Ecto
  doesn’t implicitly or explicitly detect and track data changes, which is not unexpected in a
  functional programming environment. A Repository should mimic a collection as much as possible,
  even though this repository is not a collection-based repository, i.e. it appears the collection
  is in-memory.

  A Repository hydrates an aggregate and persists the aggregate using the `save/1` function.

  The Repository is the perfect place to handle unique constraint errors and other issues related
  to collections and persistence.

  Repositories can be adapters for other stores beyond a traditional RDBMS. These may be a key-value
  store or event the file system.
  """

  alias CivilCode.{Entity, EntityId, Result}

  defmodule Behaviour do
    @moduledoc false

    @type id :: %{__struct__: atom, value: EntityId.t()}

    @doc """
    Generates an ID for an entity.
    """
    @callback next_id() :: id

    @doc """
    Retrieves an aggregate from the Repository.
    """
    @callback get(id) :: Entity.t()

    @doc """
    Persists the aggregate in the Repository.
    """
    @callback save(Entity.t()) :: Result.t(Entity.t())
  end

  defmacro __using__(_) do
    quote do
      alias CivilCode.{Entity, Result}

      @behaviour Behaviour

      def build(module, func) do
        record = func.()

        module
        |> Entity.build(record)
        |> Entity.put_assigns(:record, record)
      end
    end
  end
end
