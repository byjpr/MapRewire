# MapRewire

Syntactic sugar to simply bulk rekey maps.

### Why did I do this?

Simply because I am super lazy, and writing out functions to take maps and convert them to different keys was boring (and irritating) the shit out of me.

writing out `%{"id"=>"234923409", "title"=>"asdf"}<~['title=>name', 'id=>another_id']` is a much nicer than: `defp convert_map(data), do: %{ "another_id" => data["id"], "name" => data["title"] }`.

## Getting started

### 1. Add as a dependency

```elixir
def deps do
  [
    {:map_rewire, "~> 0.1.0"}
  ]
end
```

### 2. Download

```bash
$ mix deps.get
```

### 3 (Optionally). Want to see inside MapRewire?

Add to config.exs

```elixir
config :map_rewire,
  debug?: true
```

### 4. Run!

```bash
$ iex -S mix
```

## Usage

### Running in iex

```elixir
 iex(1)> use MapRewire
 iex(2)> %{"id"=>"234923409", "title"=>"asdf"}<~['title=>name', 'id=>shopify_id']
 [
   %{"id" => "234923409", "name" => "asdf"},
   %{"shopify_id" => "234923409", "title" => "asdf"}
 ]
```

### Running as part of a module

**Example 1:**

```elixir
defmodule Foo do
  use MapRewire

  @becomes [
    'id=>shopify_id',
    'title=>name',
    'body_html=>description'
  ]

  def bar do
    fake_factory
    |> final
  end

  defp fake_factory do
    %{
      "id" => "234923409",
      "name" => "asdf",
      "body_html" => "asdfasdf"
    }
  end

  def final(data) do
    data<~@becomes
  end
end
```

Calling `Foo.bar()` will result in the output:

```elixir
 [
   %{"id" => "234923409", "name" => "asdf", "body_html" => "asdfasdf"},
   %{"shopify_id" => "234923409", "title" => "asdf", "description" => "asdfasdf"}
 ]
```

**Example 2:**

```elixir
defmodule Foo do
  use MapRewire

  @becomes [
    'age=>years_old',
    'languages=>technologies_known',
    'name=>this'
  ]

  def bar do
    fake_factory
    |> final
  end

  defp fake_factory do
    %{
      "age"=> 31,
      "languages"=> ["Erlang", "Ruby", "Elixir"],
      "name"=> "John"
    }
  end

  def final(data) do
    data<~@becomes
  end
end
```

Calling `Foo.bar()` will result in the output:

```elixir
[
   %{ "age"=> 31, "languages"=> ["Erlang", "Ruby", "Elixir"], "name"=> "John" },
   %{ "years_old"=> 31, "technologies_known"=> ["Erlang", "Ruby", "Elixir"], "this"=> "John" }
 ]
```
