defmodule CivilCode.BusinessRuleViolation do
  @moduledoc false

  defstruct [:entity, :type]

  defmacro __using__(_) do
  end
end
