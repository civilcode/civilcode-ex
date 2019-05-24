defmodule CivilCode.RepositoryError do
  @moduledoc """
  A type for errors that occur when persisting an aggregate.

  ## Usage

  The error is returned from a Repository and generally triggered by unique constraint violations.

  ## Example

      def save(changeset) do
        result =
          changeset
          |> Ecto.Changeset.unique_constraint(:id, name: :magasin_sale_orders_pkey)
          |> Repo.insert_or_update()

        case result do
          {:ok, order} -> Result.ok(order.id)
          {:error, invalid_changeset} -> RepositoryError.validate(invalid_changeset)
        end
      end

      # => {:error, %CivilCode.RepositoryError{field_name: :id, message: "has already been taken"}}
  """
  use TypedStruct

  import Ecto.Changeset

  alias CivilCode.Result

  typedstruct enforce: true do
    field(:field_name, atom)
    field(:message, String.t())
  end

  @spec validate(Ecto.Changeset.t()) :: {:error, t}
  def validate(changeset) do
    changeset
    |> new
    |> Result.error()
  end

  defp new(changeset) do
    {field_name, message} =
      changeset
      |> build_errors()
      |> Map.to_list()
      |> List.first()

    struct(
      __MODULE__,
      field_name: field_name,
      message: message
    )
  end

  defp build_errors(changeset) do
    changeset
    |> traverse_errors(&translate_error/1)
    |> Enum.map(&format_errors/1)
    |> Enum.into(%{})
  end

  defp translate_error({msg, _opts}), do: msg

  defp format_errors({key, errors}) when is_list(errors), do: {key, List.first(errors)}

  defp format_errors({key, struct}) when is_map(struct),
    do: {key, Enum.map(struct, &format_errors/1)}
end
