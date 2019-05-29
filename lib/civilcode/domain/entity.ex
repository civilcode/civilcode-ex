defmodule CivilCode.Entity do
  @moduledoc """
  A concept in the domain that performs actions on a uniquely identified object.

  ## From the Experts

  > We design a domain concept as an Entity when we care about its individuality, when
  > distinguishing it from all other objects in a system is a mandatory constraint. An Entity is
  > a unique thing and is capable of being changed continuously over a long period of time.
  > Changes may be so extensive that the object might seem much different from what it once was.
  > Yet, it is the same object by identity.

  > These redesigned methods have a CQS query contract and act as Factories (11); that is, each
    creates a new Aggregate instance and returns a reference to it." - [IDDD]

  ## Usage

  Entities form Aggregates, one Entity in the Aggregate will act as the Aggregate Root
  (`CivilCode.Aggregate.Root`), all function calls are made through the Aggregate, creating a
  public API.

  Entities have domain actions that operate on the Entity, or return new Aggregates of a different
  type. The domain actions have no side effects, i.e. no indirect inputs, e.g. env, time.

  Entities are used in all architectures. In __Simple-Domain__ Architecture style they will have basic
  CRUD functions, i.e. `create` and `update` while __Rich-Domain__ and __Event-Driven__ Architectures will
  have domain actions.

  Entities can working on state from the Data application, known as the Data schema, or can create
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

      # Event-Based

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

  ```
      # good

      Order.completed?(order)

      # bad

      order.state == "completed"
  ```
  * Data Schemas can be alias normally as if they were lived in the "core" application.
    This reduces the amount of noise that would occur in the module when referencing with
    the full module path.
  ```
      # lib/magasin_core/sales/domain/order/order.ex
      defmodule MagasinCore.Sales.Order do
        use CivilCode.Entity

        alias MagasinData.Catalog
        alias MagasinData.Sales.Order
      end
  ```
  * Create a type `t/0` with Data Schema as this will simplify typespec signatures and make
    refactoring to a Custom schema later if required. Then all of the modules in the "core"
    application can reference that alias:

  ```
      # lib/magasin_core/sales/domain/order/order.ex
      defmodule MagasinCore.Sales.Order do
        use CivilCode.Entity

        alias MagasinData.Sales.Order

        @type t :: Order.t
      end
  ```

  Rich-Domain and Event-Based:

  * Ecto Schema is used to implement Entity schemas when needed.
  """

  defmodule Metadata do
    @moduledoc false

    @type t :: %__MODULE__{}

    defstruct events: [], assigns: %{}
  end

  @type t :: %{optional(atom) => any, __struct__: atom, __entity__: Metadata.t()}

  defmacro __using__(_) do
    quote do
      import CivilCode.Entity

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
        field(:__entity__, :map, default: %Metadata{})
      end
    end
  end

  @doc """
  Provides a space to place any kinda of data onto the entity. For example, the Repository uses
  it to track the original record used to build an Entity.
  """
  @spec put_assigns(t, atom, any) :: t
  def put_assigns(entity, key, value) do
    new_assigns = Map.put(entity.__entity__.assigns, key, value)
    updated_metadata = struct!(entity.__entity__, assigns: new_assigns)
    struct!(entity, __entity__: updated_metadata)
  end

  @spec get_assigns(t, atom) :: any
  def get_assigns(entity, key) do
    entity.__entity__.assigns[key]
  end

  @doc """
  Put changes for the entity and the event.
  """
  @spec change(t | Ecto.Changeset.t(), event :: map, fields :: map | Keyword.t()) ::
          Ecto.Changeset.t()
  def change(entity, event, fields) do
    metadata = %{entity.__entity__() | events: entity.__entity__.events ++ [event]}
    Ecto.Changeset.change(%{entity | __entity__: metadata}, fields)
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
    struct(module, fields ++ [__entity__: struct!(Metadata)])
  end
end
