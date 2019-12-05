defmodule CivilCode.ValueObject.NaiveMoneyTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  describe "inspect" do
    test "returns a string representation" do
      value = Fixtures.NaiveMoney.new!("123.45")

      inspection = fn -> IO.inspect(value) end
      assert capture_io(inspection) == "#Fixtures.NaiveMoney<$123.45>\n"
    end
  end

  describe "serializing" do
    test "returns a serialized value" do
      value = Fixtures.NaiveMoney.new!("123.45")
      serialized_value = Fixtures.NaiveMoney.serialize(value)

      assert serialized_value == %{
               "__civilcode__" => %{"type" => "Elixir.Fixtures.NaiveMoney"},
               "value" => Decimal.new("123.45")
             }
    end
  end

  describe "deserializing" do
    test "returns a deserialized value" do
      serialized_value = %{
        "__civilcode__" => %{"type" => "Elixir.Fixtures.NaiveMoney"},
        "value" => "123.45"
      }

      value = Fixtures.NaiveMoney.deserialize(serialized_value)

      assert value == Fixtures.NaiveMoney.new!("123.45")
    end
  end
end
