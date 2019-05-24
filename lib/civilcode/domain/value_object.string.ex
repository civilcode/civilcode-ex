defmodule CivilCode.ValueObject.String do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use CivilCode.ValueObject.Base

      alias CivilCode.Result

      typedstruct enforce: true do
        field(:value, String.t())
      end

      def new(value) when is_binary(value) do
        __MODULE__
        |> struct(value: value)
        |> Result.ok()
      end

      def new(_value) do
        Result.error(:must_be_a_string)
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

      defp to_ecto_result({:ok, value}), do: Result.ok(value)
      defp to_ecto_result({:error, _}), do: :error

      @impl true
      def load(value), do: new(value)

      @impl true
      def dump(%__MODULE__{} = struct), do: Result.ok(struct.value)
      def dump(_), do: :error
    end
  end
end
