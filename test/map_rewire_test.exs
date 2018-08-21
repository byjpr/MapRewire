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
         multiple_list: ["samplekey=>name", "second=>third"]
       ]
     ]}
  end

  test "Invalid content type", context do
    assert catch_error("sdf" <~> context[:transforms][:single_string])
  end

  test "Invalid transforms type", context do
    assert catch_error(context[:content][:single] <~> 234)
  end

  test "1 input, 1 rule, string", context do
    assert context[:content][:single] <~> context[:transforms][:single_string] == [
             %{"samplekey" => "samplevalue"},
             %{"name" => "samplevalue"}
           ]
  end

  test "1 input, 1 rule, list", context do
    assert context[:content][:single] <~> context[:transforms][:single_list] == [
             %{"samplekey" => "samplevalue"},
             %{"name" => "samplevalue"}
           ]
  end

  test "2 input, 2 rule, string", context do
    assert context[:content][:multiple] <~> context[:transforms][:multiple_string] == [
             %{"samplekey" => "samplevalue", "second" => "whoo"},
             %{"name" => "samplevalue", "third" => "whoo"}
           ]
  end

  test "2 input, 2 rule, list", context do
    assert context[:content][:multiple] <~> context[:transforms][:multiple_list] == [
             %{"samplekey" => "samplevalue", "second" => "whoo"},
             %{"name" => "samplevalue", "third" => "whoo"}
           ]
  end
end
