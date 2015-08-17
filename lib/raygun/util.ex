defmodule Raygun.Util do

    @moduledoc """
    This module contains utility functions for formatting particular pieces
    of stacktrace data into strings.
    """

    @doc """
    Headers are a list of Tuples. Convert them to a keyword list.
    """
    def format_headers(headers) do
      headers |> Keyword.new( fn {x,y} -> {String.to_atom(x), y} end )
    end

    @doc """
    Given a function name (atom) and arity (number), return a string in the form
    func_name/2.
    """
    def function_and_arity(function,arity) do
      "#{Atom.to_string(function)}/#{arity}"
    end

    @doc """
    Return the module name as a string (binary).
    """
    def mod_for(module) when is_atom(module) do
      Atom.to_string(module)
    end
    def mod_for(module) when is_binary(module) do
      module
    end

    @doc """
    Given stacktrace information, get the line number.
    """
    def line_from(file: _file, line: line) do
      line
    end

    @doc """
    Given stacktrace information, get the file name.
    """
    def file_from(file: file, line: _line) do
      file |> List.to_string
    end

end
