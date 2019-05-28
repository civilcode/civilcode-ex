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

  Entities can working on state from the Data application, or can create their own struct which
  is hydrated from the Aggregate Repository.

  Domain Actions will always return a valid `Ecto.Changeset.t()` unless a business rule has been violated
  then a `CivilCode.BusinessException.t()` result will be returned.

  The three examples below demonstrate a domain action in the different architecture styles:

      # Simple-Domain

      @spec deplenish(t, Params.t) :: Ecto.Changeset.t(t)
      def deplenish(stock_item, params) do
        cast(stock_item, params, [:count_on_hand]
      end

      # Rich-Domain

      @spec deplenish(t, Quantity.t) :: {:ok, Ecto.Changeset.t(t)}, {:error, OutOfStock.t}
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

      @spec deplenish(t, Quantity.t) :: {:ok, Ecto.Changeset.t(t)}, {:error, OutOfStock.t}
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

   * TypedStruct is used to implement Entity schemas when needed. Simple structs (vs Ecto-based structs)
     allow for parameterised types, e.g. Maybe.t.
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

  """

  defmodule Metadata do
    @moduledoc false

    @type t :: %__MODULE__{}

    defstruct events: [], changes: [], assigns: %{}
  end

  @type t :: %{optional(atom) => any, __struct__: atom, __entity__: Metadata.t()}

  defmacro __using__(_) do
    quote do
      import CivilCode.Entity
    end
  end

  defmacro typedstruct(do: block) do
    quote do
      use TypedStruct

      TypedStruct.typedstruct do
        unquote(block)
        field(:__entity__, Metadata.t())
      end
    end
  end

  def new(module, attrs \\ []) do
    struct!(module, attrs ++ [__entity__: struct!(Metadata)])
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

  @doc """
  Get the fields from an entity and returns them as a map. This is commonly used to build a
  changeset in a Repository.

  Example:

    Entity.get_fields(order, [:id, :email, :product_id, :quantity])
  """
  @spec get_fields(t, list(atom)) :: map
  def get_fields(entity, fields) do
    entity
    |> Map.from_struct()
    |> Map.take(fields)
  end

  @doc """
  Puts the changes for an entity. This allows tracking of changes which can later be used
  in the Repository.
  """
  @spec put_changes(struct, Keyword.t()) :: struct
  def put_changes(struct, changes) do
    struct!(struct, changes ++ [__entity__: struct!(struct.__entity__, changes: changes)])
  end

  # EVENT RELATED FUNCTIONS

  @doc """
  Updates the state of the entity based on event returned by the function. If the function
  returns an error result the entity will not be updated. The event will be tracked so it maybe
  published later.
  """
  def update(entity, func) do
    case func.(entity) do
      {:error, violation} -> {:error, violation}
      {:ok, event} -> do_update(entity, event)
      event -> do_update(entity, event)
    end
  end

  defp do_update(entity, event) do
    updated_state = apply(entity.__struct__, :apply, [entity, event])

    updated_entity =
      struct!(updated_state, __entity__: struct!(updated_state.__entity__, events: [event]))

    {:ok, updated_entity}
  end
end
