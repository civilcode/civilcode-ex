defmodule CivilCode.Result do
  @moduledoc false

  def ok(value), do: {:ok, value}

  def error(value), do: {:error, value}

  def unwrap(results) when is_list(results) do
    Enum.map(results, &unwrap/1)
  end

  def unwrap({_, value}), do: value

  def map({:ok, payload}, func), do: ok(func.(payload))
  def map(result, _func), do: result
end
