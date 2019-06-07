defmodule CivilCode.ValueObject.NonNegInteger do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use CivilCode.ValueObject.Base

      alias CivilCode.Result

      typedstruct enforce: true do
        field(:value, non_neg_integer)
      end

      # Encoding for JSON. Required when a ValueObject is serialized.
      defimpl Jason.Encoder do
        def encode(value_object, _opts) do
          Jason.Encode.integer(value_object.value)
        end
      end

      @spec new(String.t() | non_neg_integer) :: {:ok, t} | {:error, atom}
      def new(value) when is_binary(value) do
        case Ecto.Type.cast(:integer, value) do
          {:ok, casted_value} -> new(casted_value)
          :error -> Result.error("must be an integer")
        end
      end

      def new(value) when value < 0 do
        Result.error("must be negative")
      end

      def new(value) do
        __MODULE__
        |> struct(value: value)
        |> Result.ok()
      end

      defoverridable new: 1

      @behaviour Elixir.Ecto.Type

      @impl true
      def type, do: :integer

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
      def dump(%__MODULE__{} = struct), do: Result.ok(struct.value)
      def dump(_), do: :error
    end
  end
end
