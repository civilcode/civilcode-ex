defmodule CivilCode.Record do
  @moduledoc """
  A Record represents a record for a data store. This helps clarify the source of the data.
  Mostly a `CivilCode.Entity` uses the record as it's state, but an Entity may create it's own
  schema. Records are located in the "data" application.
  """
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      @type t :: %__MODULE__{}
    end
  end
end
