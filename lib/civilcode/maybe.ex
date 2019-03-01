defmodule CivilCode.Maybe do
  @moduledoc """
  Handles the presences of a value. Based on the F# type:

  https://fsharpforfunandprofit.com/posts/the-option-type/
  """
  use Currying

  @type t(value) :: {:some, value} | :none
  @type a :: any
  @type b :: any

  @spec none() :: :none
  def none, do: :none

  @spec new(nil | any) :: t(any)
  def new(nil), do: :none
  def new(value), do: {:some, value}

  @spec map(t(a), (... -> b)) :: t(b) | t((... -> b))
  def map(:none, _f), do: none()
  def map({:some, value}, f), do: new(curry(f).(value))

  @spec none?(t(a)) :: boolean
  def none?(:none), do: true
  def none?({:some, _value}), do: false

  @spec some?(t(a)) :: boolean
  def some?({:some, _value}), do: true
  def some?(:none), do: false

  @spec unwrap!({:some, a}) :: a
  def unwrap!({:some, value}), do: value

  @spec flatten(t(t(a))) :: t(a)
  def flatten(:none), do: :none
  def flatten({:some, {:some, value}}), do: flatten({:some, value})
  def flatten({:some, :none}), do: :none
  def flatten({:some, value}), do: {:some, value}
end
