defmodule CivilCode.ValueObject.UuidTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  describe "inspect" do
    test "returns a string representation" do
      value = Fixtures.Uuid.new!("297ab877-9cc7-4825-b3fe-93140a650eb5")

      inspection = fn -> IO.inspect(value) end
      assert capture_io(inspection) == "#Fixtures.Uuid<297ab877-9cc7-4825-b3fe-93140a650eb5>\n"
    end
  end

  describe "serializing" do
    test "returns a serialized value" do
      value = Fixtures.Uuid.new!("297ab877-9cc7-4825-b3fe-93140a650eb5")
      serialized_value = Fixtures.Uuid.serialize(value)

      assert serialized_value == %{
               "__civilcode__" => %{"type" => "Elixir.Fixtures.Uuid"},
               "value" => "297ab877-9cc7-4825-b3fe-93140a650eb5"
             }
    end
  end

  describe "deserializing" do
    test "returns a deserialized value" do
      serialized_value = %{
        "__civilcode__" => %{"type" => "Elixir.Fixtures.Uuid"},
        "value" => "297ab877-9cc7-4825-b3fe-93140a650eb5"
      }

      value = Fixtures.Uuid.deserialize(serialized_value)

      assert value == Fixtures.Uuid.new!("297ab877-9cc7-4825-b3fe-93140a650eb5")
    end
  end
end
