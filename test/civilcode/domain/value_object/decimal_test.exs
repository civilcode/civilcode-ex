defmodule CivilCode.ValueObject.DecimalTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  describe "new" do
    test "valid decimal string returns a decimal" do
      assert Fixtures.Decimal.new("100.0") ==
               {:ok, %Fixtures.Decimal{value: Decimal.new("100.0")}}
    end

    test "invalid decimal returns an error" do
      assert Fixtures.Decimal.new("100.00.00") == {:error, "is invalid"}
      assert Fixtures.Decimal.new(":string:") == {:error, "is invalid"}
    end
  end

  describe "inspect" do
    test "returns a string representation" do
      value = Fixtures.Decimal.new!("0.10")

      inspection = fn -> IO.inspect(value) end
      assert capture_io(inspection) == "#Fixtures.Decimal<0.10>\n"
    end
  end
end
