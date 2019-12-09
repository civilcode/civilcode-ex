defmodule CivilCode.ValueObject.IntegerTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  describe "inspect" do
    test "returns a string representation" do
      value = Fixtures.Integer.new!("123")

      inspection = fn -> IO.inspect(value) end
      assert capture_io(inspection) == "#Fixtures.Integer<123>\n"
    end
  end
end
