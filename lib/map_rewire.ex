defmodule MapRewire do
  @moduledoc """
  Complete syntactic sugar to rekey maps.

  ### Example 1

  ```elixir
   iex(1)> use MapRewire
   iex(2)> %{"id"=>"234923409", "title"=>"asdf"}<~['title=>name', 'id=>shopify_id']
   [
  	 %{"id" => "234923409", "name" => "asdf"},
  	 %{"shopify_id" => "234923409", "title" => "asdf"}
   ]```

  ### Example 2

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
  """

  require Logger

  defmacro __using__(_) do
    quote do
      import MapRewire
    end
  end

  @transform_to "=>"
  @debug Application.get_env(:map_rewire, :debug?)

  @doc false
  defmacro data <~ transforms do
    quote do
      rewire(unquote(data), unquote(transforms))
    end
  end

  # MapRewire.rewrite(%{"id"=>"234923409", "title"=>"asdf"}, ~w(title=>name id=>shopify_id))
  # %{"shopify_id"=>"234923409", "name"=>"asdf"}

  @doc """
  `MapRewire.rewrite(%{"id"=>"234923409", "title"=>"asdf"}, ~w(title=>name id=>shopify_id))`
  `MapRewire.rewrite(%{"id"=>"234923409"}, ['id=>shopify_id'])`
  """
  def rewire(content, list) when is_map(content) and is_list(list) do
    if(@debug) do
      Logger.info("rewire#content: #{inspect(content)}")
      Logger.info("rewire#list: #{inspect(list)}")
    end

    rewire_do(content, list)
  end

  def rewire(_, _),
    do: raise(ArgumentError, "Using rewire with content other than maps is not supported")

  defp rewire_do(content, list) do
    if(@debug) do
      Logger.info("rewire_do#content: #{inspect(content)}")
      Logger.info("rewire_do#list: #{inspect(list)}")
    end

    Enum.map(list, &transform_key_to_list/1)
    |> Enum.map(fn x -> replace_key(x, content) end)
  end

  @doc """
  `MapRewire.fromto_to_list('title=>name')`
  output: `['title', 'name']`
  """
  def transform_key_to_list(item) do
    if(@debug) do
      Logger.info("transform_key_to_list#item: #{inspect(item)}")
    end

    String.split("#{item}", "#{@transform_to}")
  end

  @doc """
  Takes `map`, removes key & value for `key1`, adds `key2` with the value of `key1`
  `MapRewire.replace_key([:title, :name], map)`
  """
  def replace_key([key1, key2], map) do
    if(@debug) do
      Logger.info("replace_key#key1: #{inspect(key1)}")
      Logger.info("replace_key#key2: #{inspect(key2)}")
      Logger.info("replace_key#map: #{inspect(map)}")
    end

    {value, new_map} = Map.pop(map, key1)
    Map.put_new(new_map, key2, value)
  end
end
