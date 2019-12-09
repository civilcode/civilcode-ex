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
end
