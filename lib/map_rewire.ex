defmodule MapRewire do
  @moduledoc """
  MapRewire provides functions and operators to bulk rekey maps.

  ```
  iex> %{"id" => "234923409", "title" => "asdf"} <~> ~w(title=>name id=>shopify_id)
  {:ok, %{"id" => "234923409", "title" => "asdf"}, %{"shopify_id" => "234923409", "name" => "asdf"}}
  ```
  """

  @typedoc """
  The shape of MapRewire transformation rules. These rules may be specified in
  one of several ways. Transforms specified as strings are in the form
  `left=>right` (note that there are no spaces around the arrow).

  1.  As a string with multiple transforms separated by whitespace:

      ```
      "title=>name id=>shopify_id"
      ```

  2.  As a list of strings with one transform per string:

      ```
      ["title=>name", "id=>shopify_id"]
      ```

  3.  As any enumerable that iterates as tuples:

      ```
      [title: :name, id: :shopify_id]
      [{"title", "name"}, {"id", "shopify_id"}]
      %{"title" => :name, "id" => :shopify_id}
      ```
  """
  @type transform_rules ::
          String.t()
          | list(String.t())
          | keyword
          | map
          | list({String.t() | atom, String.t() | atom})

  @debug Application.get_env(:map_rewire, :debug?)
  @transform_to "=>"
  @key_missing "<~>NoMatch<~>" <> Base.encode16(:crypto.strong_rand_bytes(16))

  require Logger

  defmacro __using__(_) do
    quote do
      import MapRewire
    end
  end

  @doc """
  Remaps the map `content` and replaces the key if it matches with an item in
  `list`. This makes `MapRewire.rewire/2` act as an operator.
  """
  def data <~> transforms do
    rewire(data, transforms, debug: false)
  end

  @doc """
  Remaps the map `content` and replaces the key if it matches with an item in
  `list`.

  ```
  iex> MapRewire.rewrite(%{"id"=>"234923409", "title"=>"asdf"}, ~w(title=>name id=>shopify_id))
  {:ok, %{"id" => "234923409", "title" => "asdf"}, %{"shopify_id" => "234923409", "name" => "asdf"}}
  ```
  """
  @spec rewire(map, transform_rules, keyword) :: {:ok, old :: map, new :: map}
  def rewire(content, rules, options \\ [])

  def rewire(content, rules, options)
      when is_map(content) and (is_list(rules) or is_binary(rules) or is_map(rules)) do
    debug = Keyword.get(options, :debug, @debug)

    if debug do
      Logger.info("[MapRewire:arg1]rewire#content: #{inspect(content)}")
      Logger.info("[MapRewire:arg2]rewire#rules: #{inspect(rules)}")
    end

    new =
      rules
      |> normalize_rules(debug)
      |> Enum.map(&rewire_entry(&1, content, debug))
      |> Enum.reject(&match?({_, @no_match}, &1))
      |> Enum.into(%{})

    {content, new}
  end

  def rewire(content, rules, _options) when is_map(content) do
    raise ArgumentError,
          "[MapRewire:content<~>rules] expected rules to be a list, map, or string." <>
            " content: `#{inspect(content)}`, rules: `#{inspect(rules)}`"
  end

  def rewire(content, _rules, _options) when not is_map(content) do
    raise ArgumentError,
          "[MapRewire:content<~>rules] expected content to be a map, got `#{inspect(content)}`"
  end

  def rewire(content, rules, _options) do
    raise ArgumentError,
          "[MapRewire:content<~>rules] bad arguments. Error reason not known. " <>
            "Please check inspections: content: `#{inspect(content)}`, rules: `#{inspect(rules)}`"
  end

  defp normalize_rules(rules, debug) when is_binary(rules) do
    if(debug, do: Logger.info("[MapRewire]normalize_rules#rules (String): #{inspect(rules)}"))

    rules
    |> String.split(~r/\s/)
    |> Enum.map(&normalize_rule(&1, debug))
  end

  defp normalize_rules(rules, debug) when is_list(rules) do
    if(debug, do: Logger.info("[MapRewire]normalize_rules#rules (List): #{inspect(rules)}"))
    Enum.map(rules, &normalize_rule(&1, debug))
  end

  defp normalize_rules(rules, debug) when is_map(rules) do
    if(debug, do: Logger.info("[MapRewire]normalize_rules#rules (Map): #{inspect(rules)}"))
    Enum.to_list(rules)
  end

  defp normalize_rule({_old, _new} = rule, debug) do
    if(debug, do: Logger.info("[MapRewire]normalize_rule#rule (Tuple): #{inspect(rule)}"))
    rule
  end

  defp normalize_rule(rule, debug) when is_binary(rule) do
    if(debug, do: Logger.info("[MapRewire]normalize_rule#rule (String): #{inspect(rule)}"))
    List.to_tuple(String.split(rule, @transform_to))
  end

  defp normalize_rule(rule, _) when is_list(rule) and length(rule) != 2 do
    raise ArgumentError,
          "[MapRewire:content<~>rules] bad argument: invalid rule format #{inspect(rule)}"
  end

  defp normalize_rule(rule, debug) when is_list(rule) do
    if(debug, do: Logger.info("[MapRewire]normalize_rule#rule (List-2): #{inspect(rule)}"))
    List.to_tuple(rule)
  end

  defp normalize_rule(rule, _) do
    raise ArgumentError,
          "[MapRewire:content<~>rules] bad argument: invalid rule format #{inspect(rule)}"
  end

  defp rewire_entry({old, new}, map, debug) do
    if(debug, do: Logger.info("[MapRewire]rewire_entry: from #{old} to #{new}"))
    {new, Map.get(map, old, @no_match)}
  end
end
