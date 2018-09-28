defmodule MapRewireTest do
  use ExUnit.Case, async: true
  use MapRewire, warn: false

  doctest MapRewire, import: true

  setup _context do
    {:ok, SampleData.sample()}
  end

  test "Invalid content type: String", context do
    assert catch_error("sdf" <~> context[:transforms][:single_string])
  end

  test "Invalid content type: Int", context do
    assert catch_error(234 <~> context[:transforms][:single_string])
  end

  test "Invalid content type: Float", context do
    assert catch_error(0.1324 <~> context[:transforms][:single_string])
  end

  test "Invalid transforms type: Int", context do
    assert catch_error(context[:content][:single] <~> 234)
  end

  test "Rule: 1 input, 1 rule, map", context do
    assert context[:content][:single] <~> %{"samplekey" => "name"} ==
             {%{"samplekey" => "samplevalue"}, %{"name" => "samplevalue"}}
  end

  test "Rule: 1 input, 1 rule, string", context do
    assert context[:content][:single] <~> context[:transforms][:single_string] ==
             {%{"samplekey" => "samplevalue"}, %{"name" => "samplevalue"}}
  end

  test "Rule: 1 input, 1 rule, list", context do
    assert context[:content][:single] <~> context[:transforms][:single_list] ==
             {%{"samplekey" => "samplevalue"}, %{"name" => "samplevalue"}}
  end

  test "Rule: 2 input, 2 rule, string", context do
    assert context[:content][:multiple] <~> context[:transforms][:multiple_string] ==
             {%{"samplekey" => "samplevalue", "second" => "whoo"},
              %{"name" => "samplevalue", "third" => "whoo"}}
  end

  test "Rule: 2 input, 2 rule, list", context do
    assert context[:content][:multiple] <~> context[:transforms][:multiple_list] ==
             {%{"samplekey" => "samplevalue", "second" => "whoo"},
              %{"name" => "samplevalue", "third" => "whoo"}}
  end

  test "Rule: 2 input, 3 rule, string", context do
    assert context[:content][:multiple] <~> context[:transforms][:multiple_plus_no_match_string] ==
             {
               %{"samplekey" => "samplevalue", "second" => "whoo"},
               %{"name" => "samplevalue", "third" => "whoo"}
             }
  end

  test "Rule: 2 input, 3 rule, list", context do
    assert context[:content][:multiple] <~> context[:transforms][:multiple_plus_no_match_list] ==
             {
               %{"samplekey" => "samplevalue", "second" => "whoo"},
               %{"name" => "samplevalue", "third" => "whoo"}
             }
  end

  test "Rule: Fake Shopify Product Data:1", context do
    assert context[:content][:fake_shopify_product_one]
           <~> context[:transforms][:fake_shopify_product_one] ==
             {
               context[:content][:fake_shopify_product_one],
               context[:expected][:fake_shopify_product_one]
             }
  end

  test "Rule: Fake Shopify Product Data:2", context do
    assert context[:content][:fake_shopify_product_two]
           <~> context[:transforms][:fake_shopify_product_two] ==
             {
               context[:content][:fake_shopify_product_two],
               context[:expected][:fake_shopify_product_two]
             }
  end
end
