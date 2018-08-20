# MapRewire

Syntactic sugar to simply bulk rekey maps.

### Why did I do this?

Simply because I am super lazy, and writing out functions to take maps and convert them to different keys was boring (and irritating) the shit out of me.

writing out `%{"id"=>"234923409", "title"=>"asdf"}<~['title=>name', 'id=>another_id']` is a much nicer than: `defp convert_map(data), do: %{ "another_id" => data["id"], "name" => data["title"] }`.

## Getting started

### Installing

```elixir
def deps do
  [
    {:map_rewire, "~> 0.1.0"}
  ]
end
```

#### Want to see inside MapRewire? (Optionally)

```elixir
config :map_rewire,
  debug?: true
```

### In iex

````elixir
 iex(1)> use MapRewire
 iex(2)> %{"id"=>"234923409", "title"=>"asdf"}<~['title=>name', 'id=>shopify_id']
 [
	 %{"id" => "234923409", "name" => "asdf"},
	 %{"shopify_id" => "234923409", "title" => "asdf"}
 ]```

### In file

```elixir
defmodule Foo do
	use MapRewire

	@becomes [
		'id=>shopify_id',
		'title=>name',
		'body_html=>description'
	]

	def bar do
		do_some_request()
		|> get_some_data
		|> final
	end

	defp do_some_request do
		#...
	end

	defp get_some_data(request) do
		#...
	end

	def final(data) do
		data<~@becomes
	end
end```
````
