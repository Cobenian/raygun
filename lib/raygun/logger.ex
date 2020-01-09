defmodule Raygun.Logger do
  @moduledoc """
  This provides a backend for Logger that will send any messages logged at
  :error to Raygun.
  """

  @behaviour :gen_event

  defstruct ignore_plug: true

  def init(__MODULE__) do
    config = Application.get_env(:logger, __MODULE__, [])
    {:ok, init(config, %__MODULE__{})}
  end

  def init({__MODULE__, opts}) when is_list(opts) do
    config =
      Application.get_env(:logger, __MODULE__, [])
      |> Keyword.merge(opts)

    {:ok, init(config, %__MODULE__{})}
  end

  defp init(config, %__MODULE__{} = state) do
    %{
      state
      | ignore_plug: Keyword.get(config, :ignore_plug, state.ignore_plug)
    }
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
  def handle_event({:error, gl, {Logger, msg, _ts, meta}}, state) when node(gl) == node() do
    case Keyword.get(meta, :crash_reason) do
      {%_{__exception__: true} = reason, stacktrace} ->
        unless state.ignore_plug && from_plug?(stacktrace) do
          Raygun.report_stacktrace(stacktrace, reason)
        end

      _other ->
        Raygun.report_message(msg)
    end

    {:ok, state}
  end

  def handle_event(_data, state) do
    {:ok, state}
  end

  def handle_info(_, state), do: {:ok, state}

  def terminate(_reason, _state), do: :ok

  def code_change(_old_vsn, state, _extra), do: {:ok, state}

  defp from_plug?(stacktrace) do
    Enum.any?(stacktrace, fn {module, function, arity, _file_line} ->
      match?({^module, ^function, ^arity}, {Plug.Cowboy.Handler, :init, 2}) ||
      match?({^module, ^function, ^arity}, {Phoenix.Endpoint.Cowboy2Handler, :init, 2}) ||
      match?({^module, ^function, ^arity}, {Phoenix.Endpoint.Cowboy2Handler, :init, 4})
    end)
  end
end
