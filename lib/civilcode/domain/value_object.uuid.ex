defmodule CivilCode.ValueObject.Uuid do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use CivilCode.ValueObject.Base

      typedstruct enforce: true do
        field(:value, String.t())
      end

      @spec new(String.t()) :: {:ok, t} | {:error, :must_be_uuid}
      def new(value) when is_nil(value), do: {:error, :must_be_uuid}

      def new(value) do
        {:ok, struct(__MODULE__, value: value)}
      end

      @behaviour Elixir.Ecto.Type

      @impl true
      def type, do: :uuid

      @impl true
      def cast(val)

      def cast(%__MODULE__{} = e), do: {:ok, e}

      def cast(value) when is_binary(value) do
        new(value)
      end

      def cast(_), do: :error

      @impl true
      def load(value) when is_binary(value) do
        {:ok, uuid} = Elixir.Ecto.UUID.load(value)
        new(uuid)
      end

      @impl true
      def dump(%__MODULE__{} = e), do: Elixir.Ecto.UUID.dump(e.value)
      def dump(_), do: :error
    end
  end
end
