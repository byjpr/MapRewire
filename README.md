# MapRewire

Syntactic sugar to simply bulk rekey maps.

### Why did I do this?

Simply because I am super lazy, and writing out functions to take maps and convert them to different keys was boring (and irritating) the shit out of me.

writing out `%{"id"=>"234923409", "title"=>"asdf"}<~['title=>name', 'id=>another_id']` is a much nicer than: `defp convert_map(data), do: %{ "another_id" => data["id"], "name" => data["title"] }`.

### Installing

```elixir
def deps do
  [
    {:map_rewire, "~> 0.1.0"}
  ]
end
```

#### Want to see inside MapRewire?

```elixir
config :map_rewire,
  debug?: true
```
