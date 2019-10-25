defmodule CivilCode.ValueObject.UuidTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  describe "inspect" do
    test "returns a string representation" do
      value = Fixtures.Uuid.new!("297ab877-9cc7-4825-b3fe-93140a650eb5")

      inspection = fn -> IO.inspect(value) end
      assert capture_io(inspection) == "#Fixtures.Uuid<297ab877-9cc7-4825-b3fe-93140a650eb5>\n"
    end
  end
end
