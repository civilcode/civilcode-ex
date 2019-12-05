defmodule CivilCode.JsonbSerializer do
  @moduledoc """
  Serialize to/from PostgreSQL's native `jsonb` format. This is useful in serializing data
  structures to an event store. This implicitly implements the EventStore.Serializer behaviour.
  """

  def serialize(%value_object{__civilcode__: _metadata} = term) do
    value_object.serialize(term)
  end

  def serialize(%_{} = term) do
    term
    |> Map.from_struct()
    |> serialize()
  end

  def serialize(term) when is_map(term) do
    term
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), serialize(v)} end)
    |> Enum.into(%{})
  end

  def serialize(term), do: term

  def deserialize(term, config) do
    case Keyword.get(config, :type, nil) do
      nil ->
        deserialize(term)

      type ->
        type
        |> String.to_existing_atom()
        |> to_struct(term)
    end
  end

  defp to_struct(type, term) do
    struct(type, deserialize(term))
  end

  defp deserialize(%{"__civilcode__" => metadata} = serialized_term) do
    value_object = Module.concat([metadata["type"]])
    value_object.deserialize(serialized_term)
  end

  defp deserialize(map) when is_map(map) do
    for {key, value} <- map, into: %{} do
      {String.to_existing_atom(key), deserialize(value)}
    end
  end

  defp deserialize(value), do: value
end
