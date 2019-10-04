defmodule CivilCode.ValueObject.Enum do
  @moduledoc false

  # This is a fork of https://gitlab.com/ex-open-source/ecto-postgres-enum. Thank you
  # [Tomasz Marek Sulima](https://gitlab.com/Eiji).

  defmacro __using__(opts) do
    quote(bind_quoted: [opts: opts], unquote: false) do
      default_type =
        __MODULE__
        |> Module.split()
        |> List.last()
        |> Macro.underscore()
        |> String.to_atom()

      schema = opts[:schema]
      type = opts[:type] || default_type
      is_atom(type) || raise "Type needs to be an atom"
      values = opts[:values] || raise "Option values (list) is required"
      values == Enum.uniq(values) || raise "Duplicates are not allowed in enum values"
      Enum.count(values) > 0 || raise "Valid enums requires at least 1 different values"
      Enum.all?(values, &is_atom/1) || raise "All values must be atoms"
      schema && (is_atom(schema) || raise "Option schema must be atom")

      use Ecto.Type
      @__input_values__ Enum.map(values, &Atom.to_string/1)
      @__output_values__ values
      @__schema__ schema
      @__type__ if is_nil(@__schema__), do: type, else: :"#{@__schema__}.#{type}"

      list = Enum.zip(@__output_values__, @__input_values__)

      [head | tail] = Enum.reverse(@__output_values__)
      ast = Enum.reduce(tail, head, &{:|, [], [&1, &2]})

      @type t :: unquote(ast)

      @impl Ecto.Type
      for {atom, string} <- list do
        def cast(unquote(atom)), do: {:ok, unquote(atom)}
        def cast(unquote(string)), do: {:ok, unquote(atom)}
      end

      def cast(_term), do: :error

      @impl Ecto.Type
      for {atom, string} <- list do
        def dump(unquote(atom)), do: {:ok, unquote(string)}
        def dump(unquote(string)), do: {:ok, unquote(string)}
      end

      def dump(_term), do: :error

      @impl Ecto.Type
      for {atom, string} <- list do
        def load(unquote(string)), do: {:ok, unquote(atom)}
      end

      def load(_value), do: :error

      @impl Ecto.Type
      def type, do: @__type__

      @doc """
      Returns list of values
      """
      @spec values :: nonempty_list(unquote(ast))
      def values, do: @__output_values__
    end
  end
end
