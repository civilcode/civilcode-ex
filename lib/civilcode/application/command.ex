defmodule CivilCode.Command do
  @moduledoc """
  A command reifies a business request. A command is passed to an ApplicationService providing
  params as Value Objects to the domain.

  ## From the Experts

  > Since the Command objects can be serialized, we can send the textual or binary representations
  > as messages over a message queue. [IDDD p. 550]

  ## Command: Application or Domain Concern?

  > controlling task management for applications [IDDD p. 549]

  Based on the text from Vernon, a Command is considered an application concern. We acknowleged
  that others have different opinions:

  > Commands belong to the core domain (just like domain events). They play an important role in the
    CQRS architecture – they explicitly represent what the clients can do with the application. Just
    like events represent what the outcome of those actions could be.

  [Are CQRS commands part of the domain model?](https://enterprisecraftsmanship.com/2019/01/31/cqrs-commands-part-domain-model/)

  ## Usage

  __Rich-Domain__ and __Event-Driven__ Architecture MUST use Commands as Entities in these architectures
  accept Value Objects only, i.e. not `CivilCode.Params.t`.

  This Command implementation uses Ecto, so it integrates with Phoenix forms seamlessly and
  can use the `Ecto.Type` backed ValueObjects.

  ## Example

      defmodule MagasinCore.Sales.PlaceOrder do
        use CivilCode.Command

        alias MagasinData.{Address, Catalog, Email, Quantity}
        alias MagasinData.Sales.OrderId

        embedded_schema do
          field :order_id, OrderId
          field :email, Email
          field :product_id, Catalog.ProductId
          field :quantity, Quantity
          embeds_one :shipping_address, Address
        end

        @spec new(Params.t()) :: Result.ok(t) | Result.error(Changeset.t(t))
        def new(params) do
          __MODULE__
          |> struct
          |> cast(ensure_map(params), [:order_id, :product_id, :email, :quantity])
          |> cast_embed(:shipping_address)
          |> cast_embed(:line_items, with: &line_item_changeset/2)
          |> validate_required([:email])
          |> apply_action(:update)
        end
      end

  ## Design Constraints

  * `Ecto.Changeset.validate_required/2` is the only validation function allowed in Entities, other
    funtions such as `Ecto.Changeset.validate_format/3` are not allowed as ValueObjects handle
    the validation of values.
  """

  defmacro __using__(_args) do
    quote do
      use Ecto.Schema

      @type t :: %__MODULE__{}

      import Ecto.Changeset
      import CivilCode.Command

      alias Ecto.Changeset
      alias CivilCode.{Params, Result}

      @primary_key false
    end
  end
end
