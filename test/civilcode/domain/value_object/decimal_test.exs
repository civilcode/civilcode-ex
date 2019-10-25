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
end
