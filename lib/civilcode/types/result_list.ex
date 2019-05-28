defmodule CivilCode.ResultList do
  @moduledoc """
  A list of `CivilCode.Result`.
  """

  alias CivilCode.Result

  @type t :: list(Result.t(any))

  @spec combine(t) :: Result.t(any)
  def combine(results) do
    results
    |> Enum.reduce(Result.ok([]), &Result.combine/2)
    |> preserve_original_order
  end

  defp preserve_original_order(result) do
    {status, list} = result
    {status, Enum.reverse(list)}
  end
end
