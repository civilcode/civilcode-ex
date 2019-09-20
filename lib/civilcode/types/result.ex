defmodule CivilCode.Result do
  @moduledoc """
  See [Railway oriented programming](https://fsharpforfunandprofit.com/posts/recipe-part2/).
  """

  @type ok(any) :: {:ok, any}
  @type error(any) :: {:error, any}
  @type t(a, b) :: ok(a) | error(b)

  @spec unwrap!({:ok, any}) :: any
  def unwrap!({:ok, payload}), do: payload

  def unwrap!({:error, value}) do
    raise "Unexpected error tuple: #{inspect(value)}"
  end

  @spec ok(any) :: ok(any)
  def ok(result), do: {:ok, result}

  @spec error(any) :: error(any)
  def error(result), do: {:error, result}

  @spec error?(t(any, any)) :: boolean
  def error?({:error, _}), do: true
  def error?(_), do: false

  @spec map(t(any, any), (any -> any)) :: t(any, any)
  def map({:ok, payload}, func), do: ok(func.(payload))
  def map(result, _func), do: result

  @spec combine(t(any, any), t(any, any)) :: {:ok, [any()]} | {:error, [any()]}
  def combine({:ok, lhr}, {:ok, rhr}) do
    {:ok, List.flatten([lhr, rhr])}
  end

  def combine({:ok, _}, {:error, rhr}) do
    {:error, List.flatten([rhr])}
  end

  def combine({:error, lhr}, {:ok, _}) do
    {:error, List.flatten([lhr])}
  end

  def combine({:error, lhr}, {:error, rhr}) do
    {:error, List.flatten([lhr, rhr])}
  end
end
