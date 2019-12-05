defmodule CivilCode.ValueObject.NonNegIntegerTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  describe "inspect" do
    test "returns a string representation" do
      value = Fixtures.NonNegInteger.new!("123")

      inspection = fn -> IO.inspect(value) end
      assert capture_io(inspection) == "#Fixtures.NonNegInteger<123>\n"
    end
  end

  describe "serializing" do
    test "returns a serialized value" do
      value = Fixtures.NonNegInteger.new!("123")
      serialized_value = Fixtures.NonNegInteger.serialize(value)

      assert serialized_value == %{
               "__civilcode__" => %{"type" => "Elixir.Fixtures.NonNegInteger"},
               "value" => 123
             }
    end
  end

  describe "deserializing" do
    test "returns a deserialized value" do
      serialized_value = %{
        "__civilcode__" => %{"type" => "Elixir.Fixtures.NonNegInteger"},
        "value" => 123
      }

      value = Fixtures.NonNegInteger.deserialize(serialized_value)

      assert value == Fixtures.NonNegInteger.new!("123")
    end
  end
end
