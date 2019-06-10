defmodule CivilCode.ValueObject do
  @moduledoc """
  Value objects measures, quantifies, or describes an `CivilCode.Entity`.

  ## Usage

  ValueObject's MUST BE used in all architecture styles. This ValueObject implementation
  implements the `Ecto.Type` so they can easily be used with building blocks implemented with
  `Ecto.Schema` such as data records and Commands.

  A number of convience modules have been provide to generate ValueObject easily, for example:

      defmodule MagasinData.Quantity do
        use CivilCode.ValueObject, type: :non_neg_integer
      end

  If more specific types are required, create your own ValueObject based on these pre-frabricated
  types.

  Composite ValueObjects can be created using an Ecto.Schema:

      defmodule MagasinData.Address do
        use CivilCode.ValueObject, type: :composite, required: [:street_address, :city, :postal_code]

        alias MagasinData.PostalCode

        embedded_schema do
          field :street_address, :string
          field :city, :string
          field :postal_code, PostalCode
        end
      end

  An enum example:

      defmodule MagasinData.OrderState do
        use CivilCode.ValueObject, type: :enum, values: [:pending, :paid, :shipped]
      end

  ## From the Experts

  > When you have a true Value Object in your model, whether you realize it or not, it is not a
  > thing in your domain. Instead, it is actually a concept that measures, quantifies, or otherwise
  > describes a thing in the domain. A person has an age. The age is not really a thing but
  > measures or quantifies the number of years the person (thing) has lived. A person has a name.
  > The name is not a thing but describes what the person (thing) is called.
  > [IDDD p. 221]

  > It may surprise you to learn that we should strive to model using Value Objects instead of
  > Entities wherever possible. Even when a domain concept must be modeled as an Entity, the
  > Entity’s design should be biased toward serv- ing as a Value container rather than a child
  > Entity container. That advice is not based on an arbitrary preference. Value types that
  > measure, quantify, or describe things are easier to create, test, use, optimize, and maintain.
  > [IDDD p. 219]

  ValueObjects are also influenced by Domain Primitives from [Secure by Design](https://books.google.ca/books?isbn=1617294357).
  For a quick overview of Domain Primitives, watch the presentation [Domain Primitives in Action: Making it Secure by Design](ps://www.youtube.com/watch?v=ogjOKlXHi08).
  """
  def enum(opts) do
    quote do
      use CivilCode.ValueObject.Enum, unquote(opts)
    end
  end

  def string(_) do
    quote do
      use CivilCode.ValueObject.String
    end
  end

  def non_neg_integer(_) do
    quote do
      use CivilCode.ValueObject.NonNegInteger
    end
  end

  def uuid(_) do
    quote do
      use CivilCode.ValueObject.Uuid
    end
  end

  def composite(opts) do
    required = Keyword.get(opts, :required)

    quote do
      use CivilCode.ValueObject.Composite

      def validate(schema), do: validate_required(schema, unquote(required))
    end
  end

  defmacro __using__(opts) do
    type = Keyword.get(opts, :type)

    apply(__MODULE__, type, [opts])
  end
end
