defmodule CivlCode.ValueObject.Decimal do
  @moduledoc """
  A value object based on a decimal.
  """

  defmacro __using__(_) do
    quote do
      use CivilCode.ValueObject.Base

      alias CivilCode.Result

      typedstruct enforce: true do
        field(:value, Decimal.t())
      end

      def new(value) when is_binary(value) do
        with {:ok, value} <- Ecto.Type.cast(:decimal, value) do
          new(value)
        end
      end

      def new(%Decimal{} = value) do
        __MODULE__
        |> struct(value: value)
        |> Result.ok()
      end

      def new(_value) do
        Result.error("is invalid")
      end

      @spec to_decimal(t) :: Decimal.t()
      def to_decimal(value_object), do: value_object.value

      defimpl String.Chars do
        def to_string(value_object) do
          Decimal.to_string(value_object.value)
        end
      end

      defoverridable new: 1

      @behaviour Elixir.Ecto.Type

      @impl true
      def type, do: :decimal

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
      def dump(%__MODULE__{} = struct), do: Ecto.Type.dump(:decimal, struct.value)
      def dump(_), do: :error
    end
  end
end
