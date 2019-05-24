defmodule CivilCode.ValueObject.Base do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use TypedStruct

      alias CivilCode.Result

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
