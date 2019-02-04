defmodule CivilCode.Validation do
  @moduledoc false
  @type t :: %__MODULE__{}

  defstruct data: nil, errors?: false, errors: []

  alias CivilCode.Result
  import Ecto.Changeset

  @spec validate(Ecto.Changeset.t(), map | nil) :: {:ok, map} | {:error, t}
  def validate(changeset, command \\ nil) do
    if changeset.valid? do
      changeset
      |> apply_changes
      |> Result.ok()
    else
      changeset
      |> new(command)
      |> Result.error()
    end
  end

  defp new(changeset, command) do
    struct(
      __MODULE__,
      data: command || changeset.data,
      errors?: true,
      errors: build_errors(changeset)
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
