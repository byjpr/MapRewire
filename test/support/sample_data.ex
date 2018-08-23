defmodule SampleData do
  def sample do
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
    ]
  end
end
