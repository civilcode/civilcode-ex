defmodule CivilCode.ValueObject.NaiveMoney do
  @moduledoc """
  A value object based on a money, however it does not track currency. So like a `NaiveDataTime`,
  this value object is `NaiveMoney`.
  """

  defmacro __using__(_) do
    quote do
      use CivilCode.ValueObject.Base, inspect: false

      alias CivilCode.Result

      typedstruct enforce: true do
        field(:__civilcode__, map, default: %{type: to_string(__MODULE__)})
        field(:value, Decimal.t())
      end

      defimpl String.Chars do
        def to_string(value_object) do
          unquote(__CALLER__.module).to_string(value_object)
        end
      end

      def new(value) when is_binary(value) or is_integer(value) do
        with {:ok, value} <- Ecto.Type.cast(:decimal, value) do
          new(value)
        end
      end

      def new(%Decimal{} = value) do
        __MODULE__
        |> struct!(value: value)
        |> Result.ok()
      end

      def new(_value) do
        Result.error("is invalid")
      end

      def to_string(value_object) do
        "$" <> Decimal.to_string(value_object.value)
      end

      defimpl Inspect do
        import Inspect.Algebra

        def inspect(value_object, opts) do
          concat(["#", to_doc(@for, opts), "<", to_string(value_object), ">"])
        end
      end

      def deserialize_value(value), do: Decimal.new(value)

      defoverridable new: 1, to_string: 1

      use Elixir.Ecto.Type

      @impl true
      def type, do: :date

      @impl true
      def cast(%__MODULE__{} = struct), do: Result.ok(struct)

      def cast(value) do
        value
        |> new()
        |> to_ecto_result
      end

      defp to_ecto_result(result) do
        case result do
          {:ok, value} -> Result.ok(value)
          {:error, msg} -> Result.error(message: msg)
        end
      end

      @impl true
      def load(value), do: new(value)

      @impl true
      def dump(%__MODULE__{} = struct), do: Ecto.Type.dump(:date, struct.value)
      def dump(_), do: :error
    end
  end
end
