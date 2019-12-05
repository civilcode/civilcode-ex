defmodule CivilCode.ValueObject.DecimalTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  describe "inspect" do
    test "returns a string representation" do
      value = Fixtures.Decimal.new!("0.10")

      inspection = fn -> IO.inspect(value) end
      assert capture_io(inspection) == "#Fixtures.Decimal<0.10>\n"
    end
  end

  describe "serializing" do
    test "returns a serialized value" do
      value = Fixtures.Decimal.new!("123.45")
      serialized_value = Fixtures.Decimal.serialize(value)

      assert serialized_value == %{
               "__civilcode__" => %{"type" => "Elixir.Fixtures.Decimal"},
               "value" => Decimal.new("123.45")
             }
    end
  end

  describe "deserializing" do
    test "returns a deserialized value" do
      serialized_value = %{
        "__civilcode__" => %{"type" => "Elixir.Fixtures.Decimal"},
        "value" => "123.45"
      }

      value = Fixtures.Decimal.deserialize(serialized_value)

      assert value == Fixtures.Decimal.new!("123.45")
    end
  end
end
