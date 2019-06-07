defmodule CivilCode.ValueObject.String do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use CivilCode.ValueObject.Base

      alias CivilCode.Result

      # Encoding for JSON. Required when a ValueObject is serialized.
      defimpl Jason.Encoder do
        def encode(value_object, opts) do
          Jason.Encode.string(value_object.value, opts)
        end
      end

      typedstruct enforce: true do
        field(:value, String.t())
      end

      def new(value) when is_binary(value) do
        __MODULE__
        |> struct(value: value)
        |> Result.ok()
      end

      def new(_value) do
        Result.error("is invalid")
      end

      defoverridable new: 1

      @behaviour Elixir.Ecto.Type

      @impl true
      def type, do: :string

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
