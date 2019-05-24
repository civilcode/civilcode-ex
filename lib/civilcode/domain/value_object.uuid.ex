defmodule CivilCode.ValueObject.Uuid do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use CivilCode.ValueObject.Base

      alias CivilCode.Result

      typedstruct enforce: true do
        field(:value, String.t())
      end

      @spec new(String.t()) :: {:ok, t} | {:error, :must_be_uuid}
      def new(value) when is_nil(value), do: Result.error(:must_be_uuid)
      def new(value) when not is_binary(value), do: Result.error(:must_be_uuid)

      def new(value) do
        __MODULE__
        |> struct(value: value)
        |> Result.ok()
      end

      @behaviour Elixir.Ecto.Type

      @impl true
      def type, do: :uuid

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
