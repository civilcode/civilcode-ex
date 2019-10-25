defmodule CivilCode.Result do
  @moduledoc """
  See [Railway oriented programming](https://fsharpforfunandprofit.com/posts/recipe-part2/).
  """

  @type ok(any) :: {:ok, any}
  @type error(any) :: {:error, any}

  @typedoc "the two-track type"
  @type t(a, b) :: ok(a) | error(b)

  @spec unwrap!(ok(any)) :: any | no_return
  def unwrap!({:ok, payload}), do: payload

  def unwrap!({:error, value}) do
    raise "Unexpected error tuple: #{inspect(value)}"
  end

  @doc """
  Convert a single value into a two-track result.
  """
  @spec ok(any) :: ok(any)
  def ok(result), do: {:ok, result}

  @doc """
  Convert a single value into a two-track result.
  """
  @spec error(any) :: error(any)
  def error(result), do: {:error, result}

  @spec ok?(t(any, any)) :: boolean
  def ok?({:ok, _}), do: true
  def ok?(_), do: false

  @spec error?(t(any, any)) :: boolean
  def error?({:error, _}), do: true
  def error?(_), do: false

  @doc """
  Convert a one-track function into a two-track function.
  """
  @spec map(t(any, any), (any -> any)) :: t(any, any)
  def map({:ok, payload}, func), do: ok(func.(payload))
  def map(result, _func), do: result

  @doc """
  Combine two result types.
  """
  @spec combine(t(any, any), t(any, any)) :: ok([any]) | error([any])
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
