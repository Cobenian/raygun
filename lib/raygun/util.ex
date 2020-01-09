defmodule Raygun.Util do
  @moduledoc """
  This module contains utility functions for formatting particular pieces
  of stacktrace data into strings.
  """

  @doc """
  Headers are a list of Tuples. Convert them to a map
  """
  def format_headers(headers) do
    Enum.reduce(headers, %{}, fn {key, value}, acc ->
      Map.put(acc, key, value)
    end)
  end

  @doc """
  Given a function name (atom) and arity (number), return a string in the form
  func_name/2.
  """
  def function_and_arity(function, list) when is_list(list) do
    function_and_arity(function, length(list))
  end

  def function_and_arity(function, arity) do
    "#{Atom.to_string(function)}/#{arity}"
  end

  @doc """
  Return the module name as a string (binary).
  """
  def mod_for(module) when is_atom(module), do: Atom.to_string(module)
  def mod_for(module) when is_binary(module), do: module

  @doc """
  Given stacktrace information, get the line number.
  """
  def line_from([]), do: "unknown"
  def line_from(file: _file, line: line), do: line

  @doc """
  Given stacktrace information, get the file name.
  """
  def file_from([]), do: "unknown"
  def file_from(file: file, line: _line), do: List.to_string(file)

  @doc """
  Like Application.get_env only for get_key function.
  """
  def get_key(app, key, default \\ nil) do
    case :application.get_key(app, key) do
      {:ok, val} -> val
      {^key, val} -> val
      _ -> default
    end
  end

  @doc """
  So in a release this seems to return {:key, value} instead of {:ok, value}
  for some reason. So we accept that form as well....
  """
  def get_env(app, key, default \\ nil) do
    app
    |> Application.get_env(key, default)
    |> read_from_system(default)
  end

  defp read_from_system({:system, env}, default), do: System.get_env(env) || default
  defp read_from_system(value, _default), do: value
end
