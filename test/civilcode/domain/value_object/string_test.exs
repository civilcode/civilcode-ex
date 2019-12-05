defmodule CivilCode.ValueObject.StringTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  describe "inspect" do
    test "returns a string representation" do
      value = Fixtures.String.new!("hello world")

      inspection = fn -> IO.inspect(value) end
      assert capture_io(inspection) == "#Fixtures.String<hello world>\n"
    end
  end

  describe "serializing" do
    test "returns a serialized value" do
      value = Fixtures.String.new!("hello world")
      serialized_value = Fixtures.String.serialize(value)

      assert serialized_value == %{
               "__civilcode__" => %{"type" => "Elixir.Fixtures.String"},
               "value" => "hello world"
             }
    end
  end

  describe "deserializing" do
    test "returns a deserialized value" do
      serialized_value = %{
        "__civilcode__" => %{"type" => "Elixir.Fixtures.String"},
        "value" => "hello world"
      }

      value = Fixtures.String.deserialize(serialized_value)

      assert value == Fixtures.String.new!("hello world")
    end
  end
end
