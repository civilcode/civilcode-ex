defmodule CivilCode.ResultTest do
  use ExUnit.Case

  alias CivilCode.Result

  test "unwrapping a result" do
    assert :payload == Result.unwrap({:ok, :payload})
    assert :payload == Result.unwrap({:error, :payload})
  end

  test "unwrapping success result" do
    assert :payload == Result.unwrap!({:ok, :payload})
  end

  test "unwrapping error result" do
    assert_raise(RuntimeError, fn -> Result.unwrap!({:error, :payload}) end)
  end

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
