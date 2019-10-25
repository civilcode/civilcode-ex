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
end
