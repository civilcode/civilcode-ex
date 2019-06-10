defmodule CivilCode.ApplicationService do
  @moduledoc """
  Fulfills a business request by handling the infrastructure and delegating to the domain model.

  # From the Experts

  > The Application Services are the direct clients of the domain model. For options on the logical
  > location of Application Service, see Architecture (4). These are responsible for task
  > coordination of use case flows, one service method per flow. When using an ACID database,
  > the Application Services also control transactions, ensuring that model state transitions
  > are atomically persisted. [IDDD p. 521]

  Application Services are typically called by a HTTP Controller in a web application provide an
  entry point to the business logic.

  ## Usage

  Application Services MUST BE used for all architecture styles. The module name reflects
  the aggregate it will delegate to, for example:

      defmodule MagasinCore.Sales.OrderApplicationService do
        use CivilCode.ApplicationService

        # Delegates to MagasinCore.Sales.Order
      end

  The use case functions typically follow as follow forming a functional sandwich (impure, pure,
  and then impure function calls):

  1. Retrieve the Aggregate from the Repository (impure function)
  2. Delegate to the Aggregate by invoking a domain actin (pure function)
  3. Persisting the Aggregate to the Repository (impure function)

  Simple-Domain:

  Functions are named representing the CRUD operation, e.g.

      defmodule ProductApplicationService do
        use CivilCode.ApplicationService

        @spec new_product() :: Changeset.t(Product.t)
        @spec create_product(Params.t) :: {:ok, Product.t} | {:error, Changeset.t(Product.t)}
        @spec edit_product(EntityId.t) :: Changeset.t(Product.t)
        @spec update_product(EntityId.t, Params.t) :: {:ok, Product.t} | {:error, Changeset.t(Product.t)}
      end

  An ApplicationService may raise exceptions with repository actions, since these are used by
  controllers only:

      `Repo.get!(Product, product_id)`

  A test for Simple-Domain Application Services are typically not necessary as they are tested
  through the controller and the Entity domain actions are unit tested.

  Rich-Domain:

  An ApplicationService will have a single `handle/1` function which pattern matches on the command.
  In this instance, the ApplicationService becomes a command handler. For example:

      defmodule MagasinCore.Sales.OrderApplicationService do
        use CivilCode.ApplicationService

        @spec handle(PlaceOrder.t) ::
          {:ok, order_id :: EntityId.t} | {:error, BusinessException.t |  RepositoryError.t}
        @spec handle(CompleteOrder.t) ::
          {:ok, order_id :: EntityId.t} | {:error, BusinessException.t | RepositoryError.t}
      end

  Rich-Domain will access the aggregate via a Repository that does not raise exceptions, it only
  returns `CivilCode.RepositoryError.t`.
  """

  defmacro __using__(_) do
    quote do
      alias Ecto.Changeset
      alias CivilCode.{EntityId, RepositoryError, Result}
    end
  end
end
