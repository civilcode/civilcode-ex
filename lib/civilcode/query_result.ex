defmodule CivilCode.QueryResult do
  @moduledoc """
  The result type for an executed query.
  Example:
      Landing
      |> Repo.get(landing_id)
      |> QueryResult.new()
  """

  alias CivilCode.Result

  @type schema :: Ecto.Schema.t()
  @type err_msg :: :not_found
  @type ok(schema) :: {:ok, schema} | {:ok, list(schema)}
  @type error(err_msg) :: {:error, err_msg}
  @type t(any) :: ok(any) | error(err_msg)

  @spec new(Ecto.Schema.t() | nil | list(Ecto.Schema.t())) ::
          t(Ecto.Schema.t() | list(Ecto.Schema.t()))
  def new(nil), do: Result.error(:not_found)
  def new(records) when is_list(records), do: Result.ok(records)
  def new(record), do: Result.ok(record)
end
