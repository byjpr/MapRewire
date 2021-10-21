# MapRewire

[![Elixir CI](https://github.com/byjpr/MapRewire/actions/workflows/elixir.yml/badge.svg)](https://github.com/byjpr/MapRewire/actions/workflows/elixir.yml)
[![Coverage Status](https://img.shields.io/coveralls/github/byjord/MapRewire.svg?style=flat-square)](https://coveralls.io/github/byjord/MapRewire)
[![Libraries.io for releases](https://img.shields.io/librariesio/release/hex/map_rewire.svg?style=flat-square)](https://libraries.io/hex/map_rewire)
[![Module Version](https://img.shields.io/hexpm/v/map_rewire.svg)](https://hex.pm/packages/map_rewire)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/map_rewire/)
[![Total Download](https://img.shields.io/hexpm/dt/map_rewire.svg)](https://hex.pm/packages/map_rewire)
[![License](https://img.shields.io/hexpm/l/map_rewire.svg)](https://github.com/byjpr/MapRewire/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/byjpr/MapRewire.svg)](https://github.com/byjpr/MapRewire/commits/master)


Bulk rekey your maps. Simple bud. (☞ﾟ ヮ ﾟ)☞

### Why?

Simply because I am _super lazy_, and writing out functions to take maps and convert them to different keys was boring (and irritating) me.

Stop writing `defp from_x_to_y(data), do: %{ "another_id" => data["id"], "name" => data["title"] }`.

### TL;DR; Syntax

1.  Macro: `content<~>transformation`, content is your data, transformation is your rules.
2.  Content: Any map. BYOD.
3.  Transformation: `from=>to`. Left is the original key, right is the new key.

## Getting started

```elixir
def deps do
  [
    {:map_rewire, "~> 0.3.0"}
  ]
end
```

## Contributors

| [![byjord](https://avatars0.githubusercontent.com/u/6415727?v=4&s=80)](https://github.com/byjord) | [![halostatue](https://avatars3.githubusercontent.com/u/11361?v=4&s=80)](https://github.com/halostatue) |
| :-----------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------: |
|                                [byjord](https://github.com/byjord)                                |                               [halostatue](https://github.com/halostatue)                               |


## Copyright and License

Copyright (c) 2018 Jordan Parker

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the [LICENSE.md](./LICENSE.md) file for more details.
