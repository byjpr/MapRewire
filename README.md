[![Hero block](https://raw.githubusercontent.com/byjord/Assets/master/MapRewire.png)](https://github.com/byjord/MapRewire)

[![Travis Build Status](https://img.shields.io/travis/byjord/MapRewire.svg?style=flat-square)](https://travis-ci.org/byjord/MapRewire)
[![Coverage Status](https://img.shields.io/coveralls/github/byjord/MapRewire.svg?style=flat-square)](https://coveralls.io/github/byjord/MapRewire)
[![Libraries.io for releases](https://img.shields.io/librariesio/release/hex/map_rewire.svg?style=flat-square)](https://libraries.io/hex/map_rewire)

Bulk rekey your maps. Simple shit bud. (☞ﾟ ヮ ﾟ)☞

* [Why did I do this?](#why-did-i-do-this)
* [TL;DR; Syntax](#tl-dr--syntax)
* [Contributors](#contributors)
* [Getting started](#getting-started)
	- [1. Add as a dependency](#1-add-as-a-dependency)
	- [2. Download](#2-download)
	- [3 (Optionally). Want to see inside MapRewire?](#3--optionally--want-to-see-inside-maprewire)
	- [4. Run!](#4-run-)
* [Usage](#usage)
	- [Running in iex](#running-in-iex)
		+ [Inline example using a list transformation](#inline-example-using-a-list-transformation)
		+ [Inline example using a string transformation](#inline-example-using-a-string-transformation)
		+ [Mixed example with a string transformation](#mixed-example-with-a-string-transformation)
		+ [Dynamic example with a string transformation](#dynamic-example-with-a-string-transformation)
		+ [Dynamic example with a list transformation](#dynamic-example-with-a-list-transformation)
	- [Running as part of a module](#running-as-part-of-a-module)

### Why did I do this?

Simply because I am _super lazy_, and writing out functions to take maps and convert them to different keys was boring (and irritating) the shit out of me.

Stop writing `defp from_x_to_y(data), do: %{ "another_id" => data["id"], "name" => data["title"] }`.

### TL;DR; Syntax

1.  Macro: `content<~>transformation`, content is your data, transformation is your rules.
2.  Content: Any map. BYOD.
3.  Transformation: `from=>to`. Left is the original key, right is the new key.

## Getting started

### 1. Add as a dependency

```elixir
def deps do
  [
    {:map_rewire, "~> 0.2.0"}
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

#### Inline example using a list transformation

```elixir
 iex(1)> use MapRewire
 iex(2)> %{"id"=>"234923409", "title"=>"asdf"}<~>["title=>name", "id=>shopify_id"]
 {:ok,
   %{"id" => "234923409", "title" => "asdf"},
   %{"shopify_id" => "234923409", "name" => "asdf"}
 }
```

#### Inline example using a string transformation

```elixir
 iex(1)> use MapRewire
 iex(2)> %{"id"=>"234923409", "title"=>"asdf"}<~>"title=>name id=>shopify_id"
 {:ok,
	 %{"id" => "234923409", "title" => "asdf"},
   %{"shopify_id" => "234923409", "name" => "asdf"}
 }
```

#### Mixed example with a string transformation

```elixir
 iex(1)> use MapRewire
 iex(2)> content = %{
	 "id"=>"234923409",
	 "title"=>"asdf",
	 "body_html"=>"asdf"
 }
 iex(3)> content<~>"title=>name id=>shopify_id body_html=>desc no_match=>wow_much_field"
 {:ok,
   %{"id" => "234923409", "title" => "asdf", "body_html" => "asdf"},
   %{"shopify_id" => "234923409", "name" => "asdf", "desc" => "asdf"}
 }
```

#### Dynamic example with a string transformation

```elixir
 iex(1)> use MapRewire
 iex(2)> content = %{
	 "id"=>"234923409",
	 "title"=>"asdf",
	 "body_html"=>"asdf"
 }
 iex(3)> transformation = "title=>name id=>shopify_id body_html=>desc no_match=>wow_much_field"
 iex(4)> content<~>transformation
 {:ok,
   %{"id" => "234923409", "name" => "title", "body_html" => "asdf"},
   %{"shopify_id" => "234923409", "name" => "asdf", "desc" => "asdf"}
 }
```

#### Dynamic example with a list transformation

```elixir
 iex(1)> use MapRewire
 iex(2)> content = %{
	 "id"=>"234923409",
	 "title"=>"asdf",
	 "body_html"=>"asdf"
 }
 iex(3)> transformation = ["title=>name", "id=>shopify_id", "body_html=>desc"]
 iex(4)> content<~>transformation
 {:ok,
   %{"id" => "234923409", "name" => "asdf", "body_html" => "asdf"},
	 %{"shopify_id" => "234923409", "name" => "asdf", "desc" => "asdf"}
 }
```

### Running as part of a module

**Example 1:**

```elixir
defmodule Foo do
  use MapRewire

  @becomes [
    "id=>shopify_id",
    "title=>name",
    "body_html=>description"
  ]

  def bar do
    fake_factory
    |> final
  end

  defp fake_factory do
    %{
      "id" => "234923409",
      "title" => "asdf",
      "body_html" => "asdfasdf"
    }
  end

  def final(data) do
    data<~>@becomes
  end
end
```

Calling `Foo.bar()` will result in the output:

```elixir
 {:ok,
   %{"id" => "234923409", "title" => "asdf", "body_html" => "asdfasdf"},
   %{"shopify_id" => "234923409", "name" => "asdf", "description" => "asdfasdf"}
 }
```

**Example 2:**

```elixir
defmodule Foo do
  use MapRewire

  @becomes "age=>years_old languages=>technologies_known name=>this"

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
    data<~>@becomes
  end
end
```

Calling `Foo.bar()` will result in the output:

```elixir
{:ok,
   %{"age" => 31, "languages" => ["Erlang", "Ruby", "Elixir"], "name" => "John"},
   %{"years_old" => 31, "technologies_known" => ["Erlang", "Ruby", "Elixir"], "this" => "John"}
 }
```

## Contributors

| [![byjord](https://avatars0.githubusercontent.com/u/6415727?v=4&s=80)](https://github.com/byjord) | [![halostatue](https://avatars3.githubusercontent.com/u/11361?v=4&s=80)](https://github.com/halostatue) |
| :-----------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------: |
|                                [byjord](https://github.com/byjord)                                |                               [halostatue](https://github.com/halostatue)                               |
