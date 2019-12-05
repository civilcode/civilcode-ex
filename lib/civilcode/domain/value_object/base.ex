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

      def new!(value) do
        {:ok, value_object} = new(value)

        value_object
      end

      def serialize(value_object) do
        %{
          "__civilcode__" => %{"type" => value_object.__civilcode__.type},
          "value" => serialize_value(value_object.value)
        }
      end

      def serialize_value(value), do: value

      def deserialize(%{"__civilcode__" => %{"type" => type}, "value" => value}) do
        struct!(Module.concat([type]), value: deserialize_value(value))
      end

      def deserialize_value(value), do: value

      defoverridable new: 1, serialize_value: 1, deserialize_value: 1

      unquote(inspect_protocol)
    end
  end
end
