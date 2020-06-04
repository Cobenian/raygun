defmodule Raygun do
  @moduledoc """
  Send errors to Raygun. Errors can be captured in three different ways.

  1. Any errors that are logged
  2. Any exceptions that occur in a Plug
  3. Programmatically

  All the functions will return `:ok` or `{:error, reason}`
  """

  @api_endpoint "https://api.raygun.io/entries"

  @doc """
  Reports a string message. This function is used by the Raygun.Logger but it
  can also be used to report any string message.
  """
  def report_message(msg, opts \\ []) do
    Raygun.Format.message_payload(msg, opts) |> send_report
  end

  @deprecated "Use report_stacktrace/2 instead"
  def report_exception(exception, opts \\ []) do
    apply(:erlang, :get_stacktrace, [])
    |> report_stacktrace(exception, opts)
  end

  @doc """
  Reports an exception and its corresponding stacktrace to Raygun.
  """
  def report_stacktrace(stacktrace, exception, opts \\ []) do
    Raygun.Format.stacktrace_payload(stacktrace, exception, opts) |> send_report
  end

  @doc """
  Reports an exception and its corresponding stacktrace to Raygun. Additionally
  this captures some additional information about the environment in which
  the exception occurred by retrieving some state from the Plug Conn.
  """
  def report_plug(conn, stacktrace, exception, opts \\ []) do
    Raygun.Format.conn_payload(conn, stacktrace, exception, opts) |> send_report
  end

  defp send_report(error) do
    headers = %{
      "Content-Type": "application/json; charset=utf-8",
      Accept: "application/json",
      "User-Agent": "Elixir Client",
      "X-ApiKey": Raygun.Util.get_env(:raygun, :api_key)
    }

    opts = Application.get_env(:raygun, :httpoison_opts, [])

    case HTTPoison.post(@api_endpoint, Jason.encode!(error), headers, opts) do
      {:ok, %HTTPoison.Response{status_code: 202}} -> :ok
      {:ok, %HTTPoison.Response{status_code: 400}} -> {:error, :bad_message}
      {:ok, %HTTPoison.Response{status_code: 403}} -> {:error, :invalid_api_key}
      {:error, _} -> {:error, :unexpected}
    end
  end
end
