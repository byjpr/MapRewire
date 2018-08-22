defmodule MapRewireTest do
  use ExUnit.Case, async: true
  use MapRewire

  setup _context do
    {:ok,
     [
       content: [
         single: %{"samplekey" => "samplevalue"},
         multiple: %{"samplekey" => "samplevalue", "second" => "whoo"},
         fake_shopify_product_one: %{
           "id" => 632_910_392,
           "handle" => "ipod-nano",
           "body_html" => "It's the small iPod with a big idea: Video.",
           "product_type" => "Cult Products",
           "published_at" => "2007-12-31T19:00:00-05:00",
           "published_scope" => "global",
           "title" => "iPod Nano"
         },
         fake_shopify_product_two: %{
           "id" => 921_728_736,
           "handle" => "ipod-touch",
           "body_html" =>
             "<p>The iPod Touch has the iPhone's multi-touch interface, with a physical home button off the touch screen. The home screen has a list of buttons for the available applications.</p>",
           "product_type" => "Cult Products",
           "published_at" => "2008-09-25T20:00:00-04:00",
           "published_scope" => "global",
           "title" => "iPod Touch"
         }
       ],
       transforms: [
         single_string: "samplekey=>name",
         single_list: ["samplekey=>name"],
         multiple_string: "samplekey=>name second=>third",
         multiple_list: ["samplekey=>name", "second=>third"],
         multiple_plus_no_match_string: "samplekey=>name second=>third no_match=>magic",
         multiple_plus_no_match_list: ["samplekey=>name", "second=>third", "no_match=>magic"],
         fake_shopify_product_one: [
           "id=>shopify_id",
           "handle=>canonical",
           "body_html=>description",
           "product_type=>type",
           "published_at=>created_at",
           "published_scope=>scope",
           "title=>name"
         ],
         fake_shopify_product_two: [
           "id=>shopify_id",
           "handle=>canonical",
           "body_html=>desc",
           "product_type=>type",
           "published_at=>launched_at",
           "published_scope=>scope",
           "title=>name"
         ]
       ],
       expected: [
         fake_shopify_product_one: %{
           "shopify_id" => 632_910_392,
           "canonical" => "ipod-nano",
           "description" => "It's the small iPod with a big idea: Video.",
           "type" => "Cult Products",
           "created_at" => "2007-12-31T19:00:00-05:00",
           "scope" => "global",
           "name" => "iPod Nano"
         },
         fake_shopify_product_two: %{
           "shopify_id" => 921_728_736,
           "canonical" => "ipod-touch",
           "desc" =>
             "<p>The iPod Touch has the iPhone's multi-touch interface, with a physical home button off the touch screen. The home screen has a list of buttons for the available applications.</p>",
           "type" => "Cult Products",
           "launched_at" => "2008-09-25T20:00:00-04:00",
           "scope" => "global",
           "name" => "iPod Touch"
         }
       ]
     ]}
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

  test "Invalid transforms type: Map", context do
    assert catch_error(context[:content][:single] <~> %{"asdf" => "asdf"})
  end

  test "Rule: 1 input, 1 rule, string", context do
    assert context[:content][:single] <~> context[:transforms][:single_string] == [
             %{"samplekey" => "samplevalue"},
             %{"name" => "samplevalue"}
           ]
  end

  test "Rule: 1 input, 1 rule, list", context do
    assert context[:content][:single] <~> context[:transforms][:single_list] == [
             %{"samplekey" => "samplevalue"},
             %{"name" => "samplevalue"}
           ]
  end

  test "Rule: 2 input, 2 rule, string", context do
    assert context[:content][:multiple] <~> context[:transforms][:multiple_string] == [
             %{"samplekey" => "samplevalue", "second" => "whoo"},
             %{"name" => "samplevalue", "third" => "whoo"}
           ]
  end

  test "Rule: 2 input, 2 rule, list", context do
    assert context[:content][:multiple] <~> context[:transforms][:multiple_list] == [
             %{"samplekey" => "samplevalue", "second" => "whoo"},
             %{"name" => "samplevalue", "third" => "whoo"}
           ]
  end

  test "Rule: 2 input, 3 rule, string", context do
    assert context[:content][:multiple] <~> context[:transforms][:multiple_plus_no_match_string] ==
             [
               %{"samplekey" => "samplevalue", "second" => "whoo"},
               %{"name" => "samplevalue", "third" => "whoo"}
             ]
  end

  test "Rule: 2 input, 3 rule, list", context do
    assert context[:content][:multiple] <~> context[:transforms][:multiple_plus_no_match_list] ==
             [
               %{"samplekey" => "samplevalue", "second" => "whoo"},
               %{"name" => "samplevalue", "third" => "whoo"}
             ]
  end

  test "Rule: Fake Shopify Product Data:1", context do
    assert context[:content][:fake_shopify_product_one]
           <~> context[:transforms][:fake_shopify_product_one] ==
             [
               context[:content][:fake_shopify_product_one],
               context[:expected][:fake_shopify_product_one]
             ]
  end

  test "Rule: Fake Shopify Product Data:2", context do
    assert context[:content][:fake_shopify_product_two]
           <~> context[:transforms][:fake_shopify_product_two] ==
             [
               context[:content][:fake_shopify_product_two],
               context[:expected][:fake_shopify_product_two]
             ]
  end
end
