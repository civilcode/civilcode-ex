defmodule CivilCode.ValueObject.NaiveMoneyTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  describe "new" do
    test "valid money string returns a money" do
      assert Fixtures.NaiveMoney.new("100.0") ==
               {:ok, %Fixtures.NaiveMoney{value: Decimal.new("100.0")}}
    end

    test "invalid money returns an error" do
      assert Fixtures.NaiveMoney.new("100.00.00") == {:error, "is invalid"}
      assert Fixtures.NaiveMoney.new(":string:") == {:error, "is invalid"}
    end
  end

  describe "inspect" do
    test "returns a string representation" do
      value = Fixtures.NaiveMoney.new!("123.45")

      inspection = fn -> IO.inspect(value) end
      assert capture_io(inspection) == "#Fixtures.NaiveMoney<$123.45>\n"
    end
  end
end
