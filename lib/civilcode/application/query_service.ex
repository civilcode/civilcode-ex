defmodule CivilCode.QueryService do
  @moduledoc """
  Query services are the entry points for queries into the application.

  ## Usage

  QueryServices are located in the web application, unless another query method is used such as
  GraphQL where then libraries such as Absinthe are used to build queries along with DataLoader.

  If domain logic has not been persisted (e.g. an order total), then a QueryService can access the
  the domain to execute the logic. This is typically done, by loading an aggregate through
  the repository and calling the domain action, e.g.:

      order_query_schema # the web-based schema
      |> OrderRepository.load # returns a Order aggegrate
      |> Order.total # returns the Order with the total calculated on the `total` field
  """

  defmacro __using__(_) do
    quote do
      alias CivilCode.QueryResult
    end
  end
end
