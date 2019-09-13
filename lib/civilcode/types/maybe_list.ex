defmodule CivilCode.MaybeList do
  @moduledoc """
  A list of `CivilCode.Maybe.t`.
  """

  alias CivilCode.Maybe

  @type t :: list(Maybe.t(any))

  @doc """
  Combine a list of Maybe's.
  """
  @spec combine(t) :: Maybe.t(any)
  def combine(maybes) do
    maybes
    |> Enum.reduce(Maybe.none(), &Maybe.combine/2)
    |> preserve_original_order
  end

  defp preserve_original_order(maybes) do
    {tag, list} = maybes
    {tag, Enum.reverse(list)}
  end
end
