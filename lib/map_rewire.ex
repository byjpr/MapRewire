defmodule MapRewire do
  @moduledoc """
  MapRewire makes it easier to rewire maps, such as might be done when
  translating from an external API result to an internal value or taking the
  output of one external API and transforming it the input shape of an entirely
  different external API.

  To rewire a map, build transformation rules and call `rewire/3`, or if
  MapRewire has been `import`ed, use the operator, `<~>`.

      iex> map   = %{"id" => "234923409", "title" => "asdf"}
      iex> rules = "title=>name id=>shopify_id"
      iex> map <~> rules
      {%{"id" => "234923409", "title" => "asdf"}, %{"shopify_id" => "234923409", "name" => "asdf"}}
      iex> MapRewire.rewire(map, rules) == (map <~> rules)
      true

  ## Rewire Rules

  The rewire rules have three basic forms.

  1.  A string containing string rename rules separated by whitespace.

      ```
      iex> map   = %{"id" => "234923409", "title" => "asdf"}
      iex> rules = "title=>name id=>shopify_id"
      iex> map <~> rules
      {%{"id" => "234923409", "title" => "asdf"}, %{"shopify_id" => "234923409", "name" => "asdf"}}
      ```

      Here, `rules` normalizes to: `[{"title", "name"}, {"id", "shopify_id"}]`.

  2.  A list of strings with one string rename rule in each string.

      ```
      iex> map   = %{"id" => "234923409", "title" => "asdf"}
      iex> rules = ["title=>name", "id=>shopify_id"]
      iex> map <~> rules
      {%{"id" => "234923409", "title" => "asdf"}, %{"shopify_id" => "234923409", "name" => "asdf"}}
      ```

      Here, rules normalizes to: `[{"title", "name"}, {"id", "shopify_id"}]`.

  3.  Any enumerable value that iterates as key/value tuples (map, keyword
      list, or a list of 2-tuples). These may be either rename rules, or may
      be more complex key transform rules.

      ```
      iex> map   = %{id: "234923409", title: "asdf"}
      iex> rules = [title: :name, id: :shopify_id]
      iex> map <~> rules
      {%{id: "234923409", title: "asdf"}, %{shopify_id: "234923409", name: "asdf"}}

      iex> map   = %{"id" => "234923409", "title" => "asdf"}
      iex> rules = [{"title", "name"}, {"id", "shopify_id"}]
      iex> map <~> rules
      {%{"id" => "234923409", "title" => "asdf"}, %{"shopify_id" => "234923409", "name" => "asdf"}}

      iex> map   = %{"id" => "234923409", "title" => "asdf"}
      iex> rules = %{"title" => :name, "id" => :shopify_id}
      iex> map <~> rules
      {%{"id" => "234923409", "title" => "asdf"}, %{shopify_id: "234923409", name: "asdf"}}

      # This is legal, but really ugly. Don't do it.
      iex> map   = %{"id" => "234923409", "title" => "asdf"}
      iex> rules = ["title=>name", {"id", "shopify_id"}]
      iex> map <~> rules
      {%{"id" => "234923409", "title" => "asdf"}, %{"shopify_id" => "234923409", "name" => "asdf"}}
      ```

  ### Rename Rules

  Rename rules take the value of the old key from the source map and write it
  to the target map as the new key, like `"title=>name"`, `%{"title" =>
  "name"}`, and `[title: :name]` that normalize to `{old_key, new_key}`. Both
  `old_key` and `new_key` are typically atoms or strings, but may be any valid
  Map key value, except for the forms noted below.

  ### Advanced Rules

  There are two types of advanced rules (keys with options and producer
  functions), which can only be provided when the rules are in an enumerable
  format such as a keyword list, map, or list of tuples.

  #### Keys with Options

  The new key is provided as a tuple `{new_key, options}`. Supported options
  are `:transform` (expecting a `t:transformer/0` function) and `:default`,
  expecting any normal map value. The `:default` will work as the third
  parameter of `Map.get/3` and be used instead of `key_missing/0`.

      iex> map   = %{"title" => "asdf"}
      iex> rules = %{"title" => {:name, transform: &String.reverse/1}}
      iex> map <~> rules
      {%{"title" => "asdf"}, %{name: "fdsa"}}

  If "title" could be missing from the source map, the `transform` function
  should be written to handle `key_missing/0` values or have its own safe
  `default` value.

      iex> map   = %{}
      iex> rules = %{"title" => {:name, default: "unknown", transform: &String.reverse/1}}
      iex> map <~> rules
      {%{}, %{name: "nwonknu"}}

  #### Producer Functions

  Producer functions (`t:producer/0`) take in the value and return zero or more
  key/value tuples. It may be provided either as `producer` or `{producer,
  options}` as shown below.

      iex> dcs = fn value ->
      ...>   unless MapRewire.key_missing?(value) do
      ...>     [dept, class, subclass] =
      ...>       value
      ...>       |> String.split("-", parts: 3)
      ...>       |> Enum.map(&String.to_integer/1)
      ...>
      ...>     Enum.to_list(%{"department" => dept, "class" => class, "subclass" => subclass})
      ...>   end
      ...> end
      iex> map   = %{"title" => "asdf", "dcs" => "1-3-5"}
      iex> rules = %{"title" => "name", "dcs" => dcs}
      iex> map <~> rules
      {%{"title" => "asdf", "dcs" => "1-3-5"}, %{"name" => "asdf", "department" => 1, "class" => 3, "subclass" => 5}}

  If "title" could be missing from the source map, the `transform` function
  should be written to handle `key_missing/0` values or have its own safe
  `default` value.

      iex> dcs = fn value ->
      ...>   [dept, class, subclass] =
      ...>     value
      ...>     |> String.split("-", parts: 3)
      ...>     |> Enum.map(&String.to_integer/1)
      ...>
      ...>   Enum.to_list(%{"department" => dept, "class" => class, "subclass" => subclass})
      ...> end
      iex> map   = %{"title" => "asdf"}
      iex> rules = %{"title" => "name", "dcs" => {dcs, default: "0-0-0"}}
      iex> map <~> rules
      {%{"title" => "asdf"}, %{"name" => "asdf", "department" => 0, "class" => 0, "subclass" => 0}}

  """

  @transform_to "=>"
  @key_missing "<~>NoMatch<~>" <> Base.encode16(:crypto.strong_rand_bytes(16))

  require Logger

  @typedoc """
  A function that, given a map `value`, produces zero or more key/value tuples.

  The `value` provided may be `key_missing/0`, so `key_missing?/1` should be
  used to compare before blindly operating on `value`.

  If no keys are to be produced (possibly because `value` is `key_missing/0`),
  either `nil` or an empty list (`[]`) should be returned.

      fn value ->
        unless MapRewire.key_missing?(value) do
          [dept, class, subclass] =
            value
            |> String.split("-", parts: 3)
            |> Enum.map(&String.to_integer/1)

          Enum.to_list(%{"department" => dept, "class" => class, "subclass" => subclass})
        end
      end
  """
  @type producer ::
          (Map.value() -> nil | {Map.key(), Map.value()} | list({Map.key(), Map.value()}))

  @typedoc """
  A function that, given a map `value`, transforms it before insertion into the
  target map.

  The `value` may be `key_missing/0`, so `key_missing?/1` should be used to
  compare before blindly operating on `value`.

  If the key should be omitted when `rewire/3` is called, `key_missing/0`
  should be returned.

      fn value ->
        cond do
          MapRewire.key_missing?(value) ->
            value

          is_binary(value) ->
            String.reverse(value)

          true ->
            String.reverse(to_string(value))
        end
      end

  """
  @type transformer :: (Map.value() -> Map.value())

  @typedoc "Advanced rewire rule options"
  @type rewire_rule_options :: [transform: transformer, default: Map.value()]

  @typedoc "Rewire rule target values."
  @type rewire_rule_target ::
          Map.key()
          | producer
          | {producer, [default: Map.value()]}
          | {Map.key(), rewire_rule_options}

  @typedoc "A normalized rewire rule."
  @type rewire_rule :: {old :: Map.key(), rewire_rule_target}

  @typedoc """
  The shape of MapRewire transformation rules.

  Note that although keyword lists and maps may be used, the values must be
  `t:rewire_rule_target/0` values.
  """
  @type rewire_rules ::
          String.t()
          | list(String.t())
          | keyword
          | map
          | list(rewire_rule)

  defmacro __using__(options) do
    if Keyword.get(options, :warn, true) do
      IO.warn(
        "use MapRewire is deprecated; import it directly instead",
        Macro.Env.stacktrace(__ENV__)
      )
    end

    quote(do: import(MapRewire))
  end

  @doc """
  The operator form of `rewire/3`, which remaps the map `content` and replaces
  the key if it matches with an item in `rewire_rules`.
  """
  def content <~> rewire_rules do
    rewire(content, rewire_rules, debug: false)
  end

  @doc """
  Remaps the map `content` and replaces the key if it matches with an item in
  `rules`.

  Accepts two options:

  -   `:debug` controls the logging of the steps taken to transform `content`
      using `rules`. The default is `Application.get_env(:map_rewire,
      :debug?)`.

  -   `:compact` which controls the removal of values from the result map for
      keys missing in the `content` map. The default is `true`.

      ```
      iex> map   = %{"title" => "asdf"}
      iex> rules = %{"title" => :name, "missing" => :missing}
      iex> rewire(map, rules, compact: true) # the default
      {%{"title" => "asdf"}, %{name: "asdf"}}

      iex> map   = %{"title" => "asdf"}
      iex> rules = %{"title" => :name, "missing" => :missing}
      iex> rewire(map, rules, compact: false)
      {%{"title" => "asdf"}, %{name: "asdf", missing: nil}}
      ```
  """
  @spec rewire(map, rewire_rules, keyword) :: {old :: map, new :: map}
  def rewire(content, rules, options \\ [])

  def rewire(content, rules, options)
      when is_map(content) and (is_list(rules) or is_binary(rules) or is_map(rules)) do
    debug = Keyword.get(options, :debug, Application.get_env(:map_rewire, :debug?)) === true

    log(debug, "[MapRewire]rewire#content: #{inspect(content)}")
    log(debug, "[MapRewire]rewire#rules: #{inspect(rules)}")
    log(debug, "[MapRewire]rewire#options: #{inspect(options)}")

    new =
      rules
      |> normalize_rules(debug)
      |> Enum.flat_map(&rewire_entry(&1, content, debug))
      |> compact(Keyword.get(options, :compact, true))
      |> Enum.reject(&match?({_, @key_missing}, &1))
      |> Enum.into(%{})

    {content, new}
  end

  def rewire(content, rules, _options) when is_map(content) do
    raise ArgumentError,
          "[MapRewire] expected rules to be a list, map, or string, got #{inspect(rules)}."
  end

  @doc """
  The value used in rewire operations if an old key does not exist in the
  source map.

  Normally, when the rewired map is produced, keys containing this value will
  be removed from the rewired map, but providing the option `compact: false` to
  `rewire/3` will replace this value with `nil`.

  The value in `key_missing/0` may be provided to `t:producer/0` and
  `t:transformer/0` functions, so `key_missing?/1` should be used to determine
  the correct response if this value is received (see the documentation for
  these function types).

  Note that the value of `key_missing/0` is a 45-byte binary value with a 13-byte
  fixed head (`"<~>NoMatch<~>"`) and a random value that changes whenever
  MapRewire is recompiled.
  """
  @spec key_missing :: binary
  def key_missing, do: @key_missing

  @doc "Returns true if `value` is the same as `key_missing/0`."
  @spec key_missing?(Map.value()) :: boolean
  def key_missing?(value), do: value === key_missing()

  @spec normalize_rules(String.t(), boolean) :: list(rewire_rule)
  defp normalize_rules(rules, debug) when is_binary(rules) do
    log(debug, "[MapRewire]normalize_rules#rules (String): #{inspect(rules)}")

    rules
    |> String.split(~r/\s/)
    |> Enum.map(&normalize_rule(&1, debug))
  end

  @spec normalize_rules(list(String.t() | rewire_rule), boolean) :: list(rewire_rule)
  defp normalize_rules(rules, debug) when is_list(rules) do
    log(debug, "[MapRewire]normalize_rules#rules (List): #{inspect(rules)}")
    Enum.map(rules, &normalize_rule(&1, debug))
  end

  @spec normalize_rules(map, boolean) :: list(rewire_rule)
  defp normalize_rules(rules, debug) when is_map(rules) do
    log(debug, "[MapRewire]normalize_rules#rules (Map): #{inspect(rules)}")
    Enum.to_list(rules)
  end

  @spec normalize_rule(String.t() | rewire_rule | list, boolean) :: rewire_rule | no_return
  defp normalize_rule({_old, _new} = rule, debug) do
    log(debug, "[MapRewire]normalize_rule#rule (Tuple): #{inspect(rule)}")
    rule
  end

  defp normalize_rule(rule, debug) when is_binary(rule) do
    log(debug, "[MapRewire]normalize_rule#rule (String): #{inspect(rule)}")
    List.to_tuple(String.split(rule, @transform_to))
  end

  defp normalize_rule(rule, _) when is_list(rule) and length(rule) != 2 do
    raise ArgumentError, "[MapRewire] bad argument: invalid rule format #{inspect(rule)}"
  end

  defp normalize_rule(rule, debug) when is_list(rule) do
    log(debug, "[MapRewire]normalize_rule#rule (List-2): #{inspect(rule)}")
    List.to_tuple(rule)
  end

  defp normalize_rule(rule, _) do
    raise ArgumentError, "[MapRewire] bad argument: invalid rule format #{inspect(rule)}"
  end

  @spec rewire_entry(rewire_rule, map, boolean) :: list({Map.key(), Map.value()})
  defp rewire_entry({old, {producer, options}}, map, debug) when is_function(producer) do
    log(
      debug,
      "[MapRewire]rewire_entry: from #{inspect(old)} with a producer function and options #{
        inspect(options)
      }"
    )

    List.wrap(producer.(Map.get(map, old, Keyword.get(options, :default, @key_missing))))
  end

  defp rewire_entry({old, {new, options}}, map, debug) do
    log(
      debug,
      "[MapRewire]rewire_entry: from #{inspect(old)} to #{inspect(new)} with options #{
        inspect(options)
      }"
    )

    value = Map.get(map, old, Keyword.get(options, :default, @key_missing))
    value = if(fun = Keyword.get(options, :transform), do: fun.(value), else: value)
    [{new, value}]
  end

  defp rewire_entry({old, producer}, map, debug) when is_function(producer) do
    log(debug, "[MapRewire]rewire_entry: from #{inspect(old)} with a producer function")
    List.wrap(producer.(Map.get(map, old, @key_missing)))
  end

  defp rewire_entry({old, new}, map, debug) do
    log(debug, "[MapRewire]rewire_entry: from #{inspect(old)} to #{inspect(new)}")
    [{new, Map.get(map, old, @key_missing)}]
  end

  @spec compact(list({Map.key(), Map.value()}), boolean) :: list({Map.key(), Map.value()})
  defp compact(rewired, true), do: Enum.reject(rewired, &match?({_, @key_missing}, &1))

  defp compact(rewired, false) do
    Enum.map(rewired, fn
      {k, @key_missing} -> {k, nil}
      pair -> pair
    end)
  end

  @spec log(boolean, String.t() | function) :: any()
  defp log(false, _), do: nil

  defp log(true, message), do: Logger.info(message)
end
