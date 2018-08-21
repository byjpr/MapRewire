# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :map_rewire, debug?: false

import_config "#{Mix.env()}.exs"
