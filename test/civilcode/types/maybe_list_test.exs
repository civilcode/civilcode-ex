defmodule CivilCode.MaybListTest do
  use ExUnit.Case

  alias CivilCode.MaybeList

  test "combining a list of maybes" do
    assert {:some, [:foo]} == MaybeList.combine([{:some, :foo}])
    assert {:some, [:foo, :bar]} == MaybeList.combine([{:some, :foo}, {:some, :bar}])
    assert {:some, [:foo]} == MaybeList.combine([{:some, :foo}, :none])
    assert :none == MaybeList.combine([:none, :none])
  end
end
