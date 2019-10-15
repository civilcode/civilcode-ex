defmodule CivilCode.ValueObject.Date do
  @moduledoc """
  A value object based on a date.
  """

  defmacro __using__(_) do
    quote do
      use CivilCode.ValueObject.Base

      alias CivilCode.Result

      typedstruct enforce: true do
        field(:value, Date.t())
      end

      def new(value) when is_binary(value) do
        with {:ok, value} <- Ecto.Type.cast(:date, value) do
          new(value)
        end
      end

      def new(%Date{} = value) do
        __MODULE__
        |> struct(value: value)
        |> Result.ok()
      end

      def new(_value) do
        Result.error("is invalid")
      end

      @spec to_date(t) :: Date.t()
      def to_date(value_object), do: value_object.value

      defimpl String.Chars do
        def to_string(value_object) do
          Date.to_string(value_object.value)
        end
      end

      defoverridable new: 1

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
