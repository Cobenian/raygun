defmodule Raygun do

  @moduledoc """
  Send errors to Raygun. Errors can be captured in three different ways.

  1. Any errors that are logged
  2. Any exceptions that occur in a Plug
  3. Programmatically
  """

  @api_endpoint "https://api.raygun.io"

  @doc """
  Reports a string message. This function is used by the Raygun.Logger but it
  can also be used to report any string message.
  """
  def report_message(msg, opts \\ %{}) do
    msg
    |> Raygun.Format.message_payload(opts)
    |> Poison.encode!
    |> send_report
  end

  @doc """
  Convenience function that captures the most recent stacktrace and reports it
  along with the exception. NOTE: it is the responsiblity of the caller to
  ensure that the most recent stacktrace is the one associated with the
  exception.
  """
  def report_exception(exception, opts \\ %{}) do
    System.stacktrace
    |> report_stacktrace(exception, opts)
  end

  @doc """
  Reports an exception and its corresponding stacktrace to Raygun.
  """
  def report_stacktrace(stacktrace, exception, opts \\ %{}) do
    stacktrace
    |> Raygun.Format.stacktrace_payload(exception, opts)
    |> Poison.encode!
    |> send_report
  end

  @doc """
  Reports an exception and its corresponding stacktrace to Raygun. Additionally
  this captures some additional information about the environment in which
  the exception occurred by retrieving some state from the Plug Conn.
  """
  def report_plug(conn, stacktrace, exception, opts \\ %{}) do
    conn
    |> Raygun.Format.conn_payload(stacktrace, exception, opts)
    |> Poison.encode!
    |> send_report
  end

  @doc """
  Send an error to Raygun.
  """
  def send_report(json) do
    headers = %{
      "Content-Type": "application/json; charset=utf-8",
      "Accept": "application/json",
      "User-Agent": "Elixir Client",
      "X-ApiKey": Application.get_env(:raygun, :api_key)
    }
    {:ok, response} = HTTPoison.post(@api_endpoint <> "/entries", json, headers)
    %HTTPoison.Response{status_code: 202} = response
  end

end
