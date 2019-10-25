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
end
