defmodule CivilCode.ValueObject.DateTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  describe "new" do
    test "valid date string returns a date" do
      assert Fixtures.Date.new("2001-01-01") == {:ok, %Fixtures.Date{value: ~D[2001-01-01]}}
    end

    test "invalid date returns an error" do
      assert Fixtures.Date.new("2001-01-00") == {:error, "is invalid"}
      assert Fixtures.Date.new("20010-01-01") == {:error, "is invalid"}
      assert Fixtures.Date.new("2000") == {:error, "is invalid"}
    end
  end

  describe "inspect" do
    test "returns a string representation" do
      value = Fixtures.Date.new!("2001-01-02")
      inspection = fn -> IO.inspect(value) end
      assert capture_io(inspection) == "#Fixtures.Date<2001-01-02>\n"
    end
  end
end
