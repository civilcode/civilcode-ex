defmodule CivilCode.Entity do
  @moduledoc """
  A concept in the domain that performs actions on a uniquely identified object.

  ## Usage

  Entities form Aggregates, one Entity in the Aggregate will act as the Aggregate Root
  (`CivilCode.AggregateRoot`), all function calls are made through the Aggregate, creating a
  public API.

  Entities have domain actions that operate on the Entity, or return new Aggregates of a different
  type. The domain actions have no side effects, i.e. no indirect inputs, e.g. env, time.

  Entities are used in all architectures. In __Simple-Domain__ Architecture style they will have basic
  CRUD functions, i.e. `create` and `update` while __Rich-Domain__ Architectures will
  have domain actions.

  Entities can working on state from the Data application, known as a `CivilCode.Record`, or can create
  their own struct which is loaded from the Aggregate Repository.

  Domain Actions will always return a valid `Ecto.Changeset.t()` unless a business rule has been violated
  then a `CivilCode.BusinessException.t()` result will be returned.

  ## Examples

  The three examples below demonstrate a domain action in the different architecture styles:

      # Simple-Domain

      @spec deplenish(t, Params.t) :: Changeset.t(t)
      def deplenish(stock_item, params) do
        cast(stock_item, params, [:count_on_hand]
      end

      # Rich-Domain

      @spec deplenish(t, Quantity.t) :: {:ok, Changeset.t(t)}, {:error, OutOfStock.t}
      def deplenish(stock_item, quantity) do
        case Quantity.subtract(stock_item.count_on_hand, quantity) do
          {:ok, new_count_on_hand} ->
             changeset = change(stock_item, count_on_hand: new_cound_on_hand)
             {:ok, changeset}

          {:error, _} ->
            {:error, OutOfStock.new(entity: stock_item)}
        end
      end

      # Rich-Domain with DomainEvent

      @spec deplenish(t, Quantity.t) :: {:ok, Changeset.t(t)}, {:error, OutOfStock.t}
      def deplenish(stock_item, quantity) do
        case Quantity.subtract(stock_item.count_on_hand, quantity) do
          {:ok, new_count_on_hand} ->
             # NOTE: The event will be published by the Repository when the Changeset is persisted
             StockItemAdjusted.new(stock_item_id: stock_item.id, new_count_on_hand: new_count_on_hand)}
             changeset = change(stock_item, event, count_on_hand: new_cound_on_hand)
             {:ok, changeset}

          {:error, _} ->
            {:error, OutOfStock.new(entity: stock_item)}
        end
      end

  ## Design Constraints

  For all architecture styles:

  * `Ecto.Changeset.validate_required/2` is the only validation function allowed in Entities, other
    funtions such as `Ecto.Changeset.validate_format/3` are not allowed as ValueObjects handle
    the validation of values.
  * For Life cycle or operational states the current state is determined via a predicate:


  ## From the Experts

  > We design a domain concept as an Entity when we care about its individuality, when
  > distinguishing it from all other objects in a system is a mandatory constraint. An Entity is
  > a unique thing and is capable of being changed continuously over a long period of time.
  > Changes may be so extensive that the object might seem much different from what it once was.
  > Yet, it is the same object by identity.

  > These redesigned methods have a CQS query contract and act as Factories (11); that is, each
    creates a new Aggregate instance and returns a reference to it." - [IDDD]
  ```
      # good

      Order.completed?(order)

      # bad

      order.state == "completed"
  ```
  * A `CivilCode.Record` can be alias normally as if they were lived in the "core" application.
    This reduces the amount of noise that would occur in the module when referencing with
    the full module path.
  ```
      # lib/magasin_core/sales/domain/order/order.ex
      defmodule MagasinCore.Sales.Order do
        use CivilCode.Entity

        alias MagasinData.Catalog
        alias MagasinData.Sales.OrderRecord
      end
  ```
  * Create a type `t/0` for a `CivilCode.Record` as this will simplify typespec signatures and make
    refactoring to a Custom schema later if required. Then all of the modules in the "core"
    application can reference that alias:

  ```
      # lib/magasin_core/sales/domain/order/order.ex
      defmodule MagasinCore.Sales.Order do
        use CivilCode.Entity

        alias MagasinData.Sales.OrderRecord

        @type t :: OrderRecord.t
      end
  ```

  Rich-Domain:

  * Ecto Schema is used to implement Entity schemas when needed.
  """

  defmodule Metadata do
    @moduledoc false

    @type t :: %__MODULE__{}

    defstruct events: [], record: nil
  end

  @type t :: %{optional(atom) => any, __struct__: atom, __civilcode__: Metadata.t()}

  defmacro __using__(_) do
    quote do
      import CivilCode.Entity
      import Ecto.Changeset

      alias CivilCode.{Params, Result}
      alias Ecto.Changeset

      def new(attrs \\ []) do
        struct!(__MODULE__, attrs)
      end
    end
  end

  defmacro embedded_schema(do: block) do
    quote do
      use Ecto.Schema

      @type t :: %__MODULE__{}

      @primary_key false

      Ecto.Schema.embedded_schema do
        unquote(block)
        field(:__civilcode__, :map, default: %Metadata{})
      end
    end
  end

  @doc """
  Put changes for the entity and the event.
  """
  @spec change(t | Ecto.Changeset.t(), event :: map, fields :: map | Keyword.t()) ::
          Ecto.Changeset.t()
  def change(entity, event, fields) do
    existing_events = get_metadata(entity, :events)

    entity
    |> put_metadata(:events, existing_events ++ [event])
    |> Ecto.Changeset.change(fields)
  end

  # REPOSITORY RELATED FUNCTIONS

  @doc """
  Builds an entity from another struct. This is used in a Repository to build an entity
  from a database record.
  """
  @spec build(module, {:ok, struct}) :: t
  def build(module, {:ok, state}), do: build(module, state)

  @spec build(module, struct) :: t
  def build(module, state) do
    fields = state |> Map.from_struct() |> Enum.into([])
    struct(module, fields ++ [__civilcode__: struct!(Metadata)])
  end

  @doc """
  Store the original database record used to build the entity.
  """
  @spec put_record(t, Ecto.Schema.t()) :: t
  def put_record(entity, record) do
    put_metadata(entity, :record, record)
  end

  @doc """
  Fetch the original database record used to build the entity.
  """
  @spec get_record(t) :: Ecto.Schema.t()
  def get_record(entity), do: entity.__civilcode__.record

  defp put_metadata(entity, key, value) do
    metadata = %{entity.__civilcode__ | key => value}
    %{entity | __civilcode__: metadata}
  end

  defp get_metadata(entity, key), do: Map.fetch!(entity.__civilcode__, key)
end
