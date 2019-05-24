defmodule CivilCode.ValueObject.NonNegInteger do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use CivilCode.ValueObject.Base

      typedstruct enforce: true do
        field(:value, non_neg_integer)
      end

      @behaviour Elixir.Ecto.Type

      def new(value) when value < 0 do
        {:error, "cannot be negative"}
      end

      def new(value) do
        {:ok, struct(__MODULE__, value: value)}
      end

      defoverridable new: 1

      @impl true
      def type, do: :integer

      @impl true
      def cast(val)

      def cast(%__MODULE__{} = struct), do: {:ok, struct}

      def cast(value) when is_number(value) do
        value
        |> new()
        |> to_ecto_result
      end

      def cast(_), do: :error

      defp to_ecto_result({:ok, value}), do: {:ok, value}
      defp to_ecto_result({:error, _}), do: :error

      @impl true
      def load(value) when is_number(value), do: new(value)

      @impl true
      def dump(%__MODULE__{} = struct), do: {:ok, struct.value}
      def dump(_), do: :error
    end
  end
end
