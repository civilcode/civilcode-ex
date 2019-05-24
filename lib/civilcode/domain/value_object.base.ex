defmodule CivilCode.ValueObject.Base do
  @moduledoc false

  alias CivilCode.Result

  defmacro __using__(_) do
    quote do
      use TypedStruct

      def new(value) do
        __MODULE__
        |> struct(value: value)
        |> Result.ok()
      end

      defoverridable new: 1

      def new!(value) do
        {:ok, primitive} = new(value)

        primitive
      end
    end
  end
end
