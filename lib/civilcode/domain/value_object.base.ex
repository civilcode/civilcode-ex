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
        {:ok, value_object} = new(value)

        value_object
      end

      defimpl Inspect do
        import Inspect.Algebra

        def inspect(value_object, opts) do
          concat([to_doc(@for, opts), "<", to_doc(value_object.value, opts), ">"])
        end
      end
    end
  end
end
