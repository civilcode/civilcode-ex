defmodule CivilCode.ValueObject.DateTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  describe "inspect" do
    test "returns a string representation" do
      value = Fixtures.Date.new!("2001-01-02")

      inspection = fn -> IO.inspect(value) end
      assert capture_io(inspection) == "#Fixtures.Date<2001-01-02>\n"
    end
  end

  describe "serializing" do
    test "returns a serialized value" do
      value = Fixtures.Date.new!("2001-01-02")
      serialized_value = Fixtures.Date.serialize(value)

      assert serialized_value == %{
               "__civilcode__" => %{"type" => "Elixir.Fixtures.Date"},
               "value" => ~D[2001-01-02]
             }
    end
  end

  describe "deserializing" do
    test "returns a deserialized value" do
      serialized_value = %{
        "__civilcode__" => %{"type" => "Elixir.Fixtures.Date"},
        "value" => ~D[2001-01-02]
      }

      value = Fixtures.Date.deserialize(serialized_value)

      assert value == Fixtures.Date.new!("2001-01-02")
    end
  end
end
