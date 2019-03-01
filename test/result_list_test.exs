defmodule CivilCode.ResultListTest do
  use ExUnit.Case

  alias CivilCode.ResultList

  test "combining a list of results" do
    assert {:ok, [:foo]} == ResultList.combine([{:ok, :foo}])
    assert {:ok, [:foo, :bar]} == ResultList.combine([{:ok, :foo}, {:ok, :bar}])
    assert {:error, [:baz]} == ResultList.combine([{:ok, :foo}, {:error, :baz}])
  end
end
