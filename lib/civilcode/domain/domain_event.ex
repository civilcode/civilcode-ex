defmodule CivilCode.DomainEvent do
  @moduledoc """
  A Domain Event captures an important occurrence in the domain.

  > A Domain Event is a record of some business-significant occurrence in a Bounded Context. [DDDDistilled p. 99]

  ## Usage

  ### Event-Driven Architecture (EDA)

  Other Bounded Contexts subscribe to Domain Events. Use Domain Events for inter-context/application
  communication (i.e. communicate Sales with Inventory), but not intra-context communication.
  If multiple aggregates need to be co-ordinated for a single business request in the same context,
  use a DomainService.

  Ref: [Domain events: simple and reliable solution](https://enterprisecraftsmanship.com/2017/10/03/domain-events-simple-and-reliable-solution/)

  Only the AggregateRoot produces DomainEvents.

  ### Rich-Domain Architecture

  In a Rich-Domain Architecture an event-bus is not present, therefore inter-context communication
  MUST BE implemented in the ApplicationService module, not in the Aggregate or Domain Service.
  This will create a unidirectional coupling, i.e. Sales -> Inventory, i.e. Sales is dependent on
  Inventory, but not the reverse.

  Domain Events MAY BE used to separate business logic from state manipulation even if they
  are not published. This is a technique to use to provide a level of isolation from Ecto.Changesets.

  For example:

      # Public API

      def deplenish(stock_item, quantity) do
        case Quantity.subtract(stock_item.count_on_hand, quantity) do
          {:ok, new_count_on_hand} ->
            {:ok, apply(stock_item, StockItemAdjusted.new(stock_item_id: state.id, new_count_on_hand: new_count_on_hand)) }
          {:error, _} ->
            {:error, OutOfStock.new(entity: stock_item)}
        end
      end

      # State Mutators

      @doc false
      def apply(stock_item, %StockItemAdjusted{} = event) do
        put_changes(stock_item, count_on_hand: event.new_count_on_hand)
      end
  """

  defmacro __using__(_) do
    quote do
      use TypedStruct

      def new(params), do: struct(__MODULE__, params)
    end
  end
end
