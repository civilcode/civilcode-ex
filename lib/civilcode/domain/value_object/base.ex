defmodule CivilCode.ValueObject.Base do
  @moduledoc false

  defmacro __using__(opts \\ []) do
    inspect_protocol =
      if Keyword.get(opts, :inspect, true) do
        quote do
          defimpl Inspect do
            import Inspect.Algebra

            def inspect(value_object, opts) do
              concat(["#", to_doc(@for, opts), "<", to_string(value_object.value), ">"])
            end
          end
        end
      end

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

      unquote(inspect_protocol)
    end
  end
end
