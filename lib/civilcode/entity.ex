defmodule CivilCode.Entity do
  @moduledoc """
  ## Life cycle or operational states

  Determining the current state is done via a predicate:

  ```elixir

  # good

  Order.completed?(order)

  # bad

  order.state == "completed"
  ```
  """

  defmodule Metadata do
    @moduledoc false

    @type t :: %__MODULE__{}

    defstruct events: [], changes: [], assigns: %{}
  end

  @type t :: %{optional(atom) => any, __struct__: atom, __entity__: Metadata.t()}

  defmacro __using__(_) do
  end

  @spec new(module, Keyword.t()) :: t
  def(new(module, attrs \\ [])) do
    struct!(module, attrs ++ [__entity__: struct!(Metadata)])
  end

  def build(module, state) do
    fields = state |> Map.from_struct() |> Enum.into([])
    struct(module, fields ++ [__entity__: struct!(Metadata)])
  end

  def get_changes(struct) do
    struct.__entity__.changes
  end

  def get_state(struct) do
    struct
  end

  def put_assigns(struct, key, value) do
    new_assigns = Map.put(struct.__entity__.assigns, key, value)
    new_entity = struct!(struct.__entity__, assigns: new_assigns)
    struct!(struct, __entity__: new_entity)
  end

  def get_assigns(struct, key) do
    struct.__entity__.assigns[key]
  end

  def apply_event(struct, func) do
    case func.(struct) do
      {:error, violation} -> {:error, violation}
      {:ok, event} -> do_apply_event(struct, event)
      event -> do_apply_event(struct, event)
    end
  end

  def get_fields(struct, fields) do
    struct
    |> Map.from_struct()
    |> Map.take(fields)
  end

  defp do_apply_event(struct, event) do
    new_state = apply(struct.__struct__, :apply, [struct, event])
    new_struct = struct!(new_state, __entity__: struct!(new_state.__entity__, events: [event]))

    {:ok, new_struct}
  end

  @spec put_changes(struct, Keyword.t()) :: struct
  def put_changes(struct, changes) do
    struct!(struct, changes ++ [__entity__: struct!(struct.__entity__, changes: changes)])
  end
end
