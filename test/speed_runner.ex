defmodule SpeedRunner do
  @moduledoc false

  import ExProf.Macro

  @data SampleData.sample()

  @doc "analyze with profile macro"
  def do_analyze do
    content = @data[:content][:fake_shopify_product_one]
    transforms = @data[:transforms][:fake_shopify_product_one]

    profile do
      content <~> transforms
    end
  end

  @doc "get analysis records and sum them up"
  def run do
    do_analyze
  end
end
