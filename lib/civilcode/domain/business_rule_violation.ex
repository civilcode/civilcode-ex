defmodule CivilCode.BusinessRuleViolation do
  @moduledoc """
  A voliation of a business rule when an Entity executes a domain action.

  ## Usage

  Used in a Rich-Domain.

  An example:

      if in_stock?(quantity)
        update(%StockItemDeplinished{quantity: quantity})
      else
        {:error, OutOfStock.new(entity: stock_item)}
      end
  """

  defmacro __using__(_) do
    quote do
      defstruct [:entity]

      def new(params), do: struct!(__MODULE__, params)
    end
  end
end
