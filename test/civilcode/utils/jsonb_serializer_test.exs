defmodule CivilCode.JsonbSerializerTest do
  use ExUnit.Case

  alias CivilCode.JsonbSerializer

  describe "serializing" do
    test "serialize" do
      term = Fixtures.String.new!("hello world")
      seralized_term = JsonbSerializer.serialize(%{nested: term})

      assert seralized_term == %{
               "nested" => %{
                 "__civilcode__" => %{"type" => "Elixir.Fixtures.String"},
                 "value" => "hello world"
               }
             }
    end
  end

  describe "deserializing" do
    test "deserialize" do
      seralized_term = %{
        "nested" => %{
          "__civilcode__" => %{"type" => "Elixir.Fixtures.String"},
          "value" => "hello world"
        }
      }

      term = JsonbSerializer.deserialize(seralized_term, [])

      assert term == %{nested: Fixtures.String.new!("hello world")}
    end
  end
end
