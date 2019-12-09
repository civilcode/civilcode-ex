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
end
