defmodule CivilCode.DomainEvent do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use TypedStruct
    end
  end
end
