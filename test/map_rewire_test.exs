defmodule MapRewireTest do
  use ExUnit.Case
  use MapRewire

  doctest MapRewire

  test "1" do
    assert %{"samplekey" => "samplevalue"} <~> "samplekey=>name" == [%{"name" => "samplevalue"}]
  end

  test "2" do
    assert(
      %{"samplekey" => "samplevalue", "second" => "whoo"}
      <~> "samplekey=>name second=>third never_matching=>30" ==
        [
          %{"name" => "samplevalue", "second" => "whoo"},
          %{"samplekey" => "samplevalue", "third" => "whoo"}
        ]
    )
  end

  test "3" do
    assert(
      %{"samplekey" => "samplevalue", "second" => "whoo"} <~> ["samplekey=>name", "second=>third"] ==
        [
          %{"name" => "samplevalue", "second" => "whoo"},
          %{"samplekey" => "samplevalue", "third" => "whoo"}
        ]
    )
  end
end
