defmodule CivilCode.ValueObject.Uuid do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use CivilCode.ValueObject.Base

      alias CivilCode.Result

      typedstruct enforce: true do
        field(:value, String.t())
      end

      defimpl String.Chars do
        def to_string(struct) do
          to_string(struct.value)
        end
      end

      # Encoding for JSON. Required when a ValueObject is serialized.
      defimpl Jason.Encoder do
        def encode(value_object, opts) do
          Jason.Encode.string(value_object.value, opts)
        end
      end

      @spec new(String.t()) :: {:ok, t} | {:error, String.t()}
      def new(value) when is_nil(value), do: Result.error("is invalid")
      def new(value) when not is_binary(value), do: Result.error("is invalid")

      def new(value) do
        __MODULE__
        |> struct(value: value)
        |> Result.ok()
      end

      use Elixir.Ecto.Type

      @impl true
      def type, do: :uuid

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
      def load(value) when is_binary(value) do
        {:ok, uuid} = Elixir.Ecto.UUID.load(value)
        new(uuid)
      end

      @impl true
      def dump(%__MODULE__{} = uuid), do: Elixir.Ecto.UUID.dump(uuid.value)
      def dump(_), do: :error
    end
  end
end
