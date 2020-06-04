defmodule Raygun.Logger do
  @behaviour :gen_event

  @moduledoc """
  This provides a backend for Logger that will send any messages logged at
  :error to Raygun.
  """

  def init(args) do
    {:ok, args}
  end

  @doc """
  Our module doesn't require any custom configuration, so just return the state.
  """
  def handle_call({:configure, _options}, state) do
    {:ok, :ok, state}
  end

  @doc """
  Match any errors that are logged. Send them on to Raygun.
  """
  def handle_event({:error, gl, {Logger, msg, _ts, _md}}, state) when node(gl) == node() do
    if Exception.exception?(msg) do
      Raygun.report_stacktrace(msg, apply(:erlang, :get_stacktrace, []))
    else
      Raygun.report_message(msg)
    end

    {:ok, state}
  end

  def handle_event(_data, state) do
    {:ok, state}
  end

  def handle_info(_msg, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def code_change(_old, state, _extra) do
    {:ok, state}
  end
end
