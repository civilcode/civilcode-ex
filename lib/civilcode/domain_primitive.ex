defmodule CivilCode.DomainPrimitive do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      @type t :: %__MODULE__{}

      @behaviour Elixir.Ecto.Type

      alias CivilCode.Result

      def cast(value) do
        case new(value) do
          {:ok, _} = result -> result
          {:error, _} -> :error
        end
      end

      def type, do: :error
      def load(_), do: :error
      def dump(_), do: :error
    end
  end
end
