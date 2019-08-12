defmodule CivilCode.MaybeTest do
  use ExUnit.Case

  alias CivilCode.Maybe

  describe "wrapping a non-nil value" do
    test "non-nil value is wrapped in a Maybe" do
      assert Maybe.some(1) == {:some, 1}
    end

    test "nil value crashes" do
      assert_raise RuntimeError, "Maybe.some/1 expects a non-nil value", fn ->
        Maybe.some(nil)
      end
    end
  end

  describe "new maybe" do
    test "nil value returns a none type" do
      assert :none == Maybe.new(nil)
    end

    test "any value returns a some type" do
      assert {:some, :foo} == Maybe.new(:foo)
    end
  end

  describe "mapping" do
    test "none returns none" do
      assert :none == Maybe.map(:none, fn term -> {:bar, term} end)
    end

    test "some returns some value" do
      assert {:some, {:foo, :bar}} == Maybe.map({:some, :foo}, fn term -> {term, :bar} end)
    end
  end

  describe "determine if the type is none" do
    test "none returns true" do
      assert Maybe.none?(:none)
    end

    test "some returns false" do
      refute Maybe.none?({:some, :foo})
    end
  end

  describe "determine if the type is some" do
    test "some returns true" do
      assert Maybe.some?({:some, :foo})
    end

    test "none returns false" do
      refute Maybe.some?(:none)
    end
  end

  describe "flatten" do
    test "with some types" do
      assert {:some, :foo} == Maybe.flatten({:some, {:some, {:some, :foo}}})
    end

    test "none returns none" do
      assert :none == Maybe.flatten(:none)
    end

    test "some of none returns none" do
      assert :none == Maybe.flatten({:some, :none})
    end
  end

  describe "combine" do
    test "some types" do
      assert {:some, [:foo, :bar]} == Maybe.combine({:some, :foo}, {:some, :bar})
    end

    test "some and none" do
      assert {:some, [:foo]} == Maybe.combine({:some, :foo}, :none)
      assert {:some, [:foo]} == Maybe.combine(:none, {:some, :foo})
    end

    test "none" do
      assert :none == Maybe.combine(:none, :none)
    end
  end
end
