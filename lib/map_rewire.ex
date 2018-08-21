defmodule MapRewire do
  @debug Application.get_env(:map_rewire, :debug?)
  @transform_to "=>"

  @moduledoc """
  Syntactic sugar to simply bulk rekey maps. MapRewire takes two arguments, data (map) and transformation (list of transformations / string of transformations separated by whitespace).

  1.  Main Syntax: `left<~>right` (`content<~>transformation`). Left value is the map that holds the data and keys you would like to update, Right value is an Elixir List that contains a string for each of the keys that you would like to update.
  2.  Transformation Syntax: `left=>right` (`from=>to`). Left is the original key, right is the new key.
  3.  Return Syntax: `[left, right]` (`[ original, rekeyed ]`). `left` is the original map. `right` is the new, rekeyed, map.
  """

  require Logger

  defmacro __using__(_) do
    quote do
      import MapRewire
    end
  end

  @doc """
  Macro syntax sugar to enable calling `rewire` in an elixir like way.

  **Input params:**
  1. `data` is passed as `content`
  2. `transforms` is passed as `list` or `binary`.

  **Output:**

  `[left, right]` (`[ original, rekeyed ]`). `left` is the original map. `right` is the new, rekeyed, map.
  """
  defmacro data <~> transforms do
    quote do
      rewire(unquote(data), unquote(transforms))
    end
  end

  @doc """
  Maps over the Enum `content` and replaces the key if it matches with an item in `list`.

  **Example 1:**

  ```MapRewire.rewrite(%{"id"=>"234923409", "title"=>"asdf"}, ~w(title=>name id=>shopify_id))```

  **Example 2:**

  ```MapRewire.rewrite(%{"id"=>"234923409"}, ['id=>shopify_id'])```
  """
  def rewire(content, list) when is_map(content) and is_list(list) do
    if(@debug) do
      Logger.info("[MapRewire:arg1]rewire#content: #{inspect(content)}")
      Logger.info("[MapRewire:arg2]rewire#list: #{inspect(list)}")
    end

    rewire_do(content, list)
  end

  def rewire(content, binary) when is_map(content) and is_binary(binary) do
    if(@debug) do
      Logger.info("[MapRewire:arg1]rewire#content: #{inspect(content)}")
      Logger.info("[MapRewire:arg2]rewire#binary: #{inspect(binary)}")
    end

    list = String.split("#{binary}", " ")
    rewire_do(content, list)
  end

  #
  # Rewire raise statements
  #
  def rewire(arg1, arg2)
      when is_map(arg1) == false and (is_list(arg2) == false or is_binary(arg2) == false),
      do:
        raise(
          ArgumentError,
          "[MapRewire:arg1<~>arg2] bad arguments. Arg1 should be a map, Arg2 should be a list or string." <>
            " Arg1: `#{inspect(arg1)}`, Arg2: `#{inspect(arg2)}`"
        )

  def rewire(arg1, _arg2) when is_map(arg1) == false,
    do:
      raise(
        ArgumentError,
        "[MapRewire:arg1<~>arg2] bad argument. Expected Arg1 to be a map, got `#{inspect(arg1)}`"
      )

  def rewire(_arg1, arg2) when is_list(arg2) == false and is_binary(arg2) == false,
    do:
      raise(
        ArgumentError,
        "[MapRewire:arg1<~>arg2] bad argument. Expected Arg2 to be a list or string, got `#{
          inspect(arg2)
        }`"
      )

  def rewire(arg1, arg2),
    do:
      raise(
        ArgumentError,
        "[MapRewire:arg1<~>arg2] bad arguments. Error reason not known. Please check inspections: " <>
          " Arg1: `#{inspect(arg1)}`, Arg2: `#{inspect(arg2)}`"
      )

  # logic for rewire
  defp rewire_do(content, list) do
    if(@debug) do
      Logger.info("[MapRewire:arg1]rewire_do#content: #{inspect(content)}")
      Logger.info("[MapRewire:arg2]rewire_do#list: #{inspect(list)}")
    end

    transform_list = rewire_do_create_transform_list(list)

    [
      content,
      recursion(transform_list, content)
    ]
  end

  defp rewire_do_create_transform_list(input) do
    if(@debug) do
      Logger.info("[MapRewire]rewire_do_create_transform_list#input: #{inspect(input)}")
    end

    Enum.map(input, &transform_key_to_list/1)
  end

  defp transform_key_to_list(item) do
    if(@debug) do
      Logger.info("[MapRewire]transform_key_to_list#item: #{inspect(item)}")
    end

    String.split("#{item}", "#{@transform_to}")
  end

  defp recursion([key1, key2], map) when is_binary(key1) and is_binary(key2),
    do: replace_key([key1, key2], map)

  defp recursion([], map), do: map

  defp recursion([head | tail], map) when is_list(head) and is_list(tail) do
    new_map = replace_key(head, map)
    recursion(tail, new_map)
  end

  # Takes `map`, removes key & value for `key1`, adds `key2` with the value of `key1`
  # `MapRewire.replace_key([:title, :name], map)`
  defp replace_key([key1, key2], map) do
    if(@debug) do
      Logger.info("[MapRewire]replace_key#key1: #{inspect(key1)}")
      Logger.info("[MapRewire]replace_key#key2: #{inspect(key2)}")
      Logger.info("[MapRewire]replace_key#map: #{inspect(map)}")
    end

    {value, new_map} = Map.pop(map, key1)
    Map.put_new(new_map, key2, value)
  end
end
