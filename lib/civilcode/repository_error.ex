defmodule CivilCode.RepositoryError do
  @moduledoc false
  @type t :: %__MODULE__{}

  defstruct [:field_name, :message]

  import Ecto.Changeset
  alias CivilCode.Result

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
