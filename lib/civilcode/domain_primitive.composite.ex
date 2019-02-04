defmodule CivilCode.DomainPrimitive.Composite do
  @moduledoc false

  alias CivilCode.Validation

  defmacro __using__(_) do
    quote do
      alias CivilCode.DomainPrimitive.Composite
      @type t :: %__MODULE__{}

      use Ecto.Schema

      import Ecto.Changeset

      def new(params), do: Composite.new(__struct__(), params)
      def new!(params), do: Composite.new!(__struct__(), params)
      def changeset(struct, params), do: Composite.changeset(struct, params)
    end
  end

  def new(domain_primitive, params) do
    domain_primitive
    |> domain_primitive.__struct__.changeset(params)
    |> Validation.validate()
    |> case do
      {:error, validation} -> {:error, validation.errors}
      result -> result
    end
  end

  def new!(module, params) do
    {:ok, struct} = new(module, params)
    struct
  end

  def changeset(struct, params) do
    fields =
      struct
      |> Map.delete(:__struct__)
      |> Map.delete(:id)
      |> Map.keys()

    struct
    |> Ecto.Changeset.cast(params, fields)
    |> struct.__struct__.validate
  end
end
