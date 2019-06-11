defmodule CivilCode.ResultTest do
  use ExUnit.Case

  alias CivilCode.Result

  test "combining a result" do
    assert {:ok, [:foo, :bar]} == Result.combine({:ok, :foo}, {:ok, :bar})
    assert {:ok, [:foo, :bar]} == Result.combine({:ok, :foo}, {:ok, [:bar]})

    assert {:error, [:baz]} == Result.combine({:ok, :foo}, {:error, :baz})
    assert {:error, [:baz]} == Result.combine({:ok, :foo}, {:error, [:baz]})
    assert {:error, [:baz]} == Result.combine({:error, :baz}, {:ok, :bar})
    assert {:error, [:baz]} == Result.combine({:error, :baz}, {:ok, [:bar]})

    assert {:error, [:baz, :qux]} == Result.combine({:error, :baz}, {:error, :qux})
    assert {:error, [:baz, :qux]} == Result.combine({:error, :baz}, {:error, [:qux]})
  end
end
