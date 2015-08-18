defmodule Raygun.Plug do
  @moduledoc """
  This plug is designed to wrap calls in a router (commonly in Phoenix) so that
  any exceptions will be sent to Raygun.
  """

  @user_fn nil

  defmacro __using__(env) do
    @user_fn = env
    quote location: :keep do
      @before_compile Raygun.Plug
    end
  end

  @doc """
  Whenever an error occurs, capture the stacktrace and exception to send to Raygun.
  """
  defmacro __before_compile__(_env) do
    quote location: :keep do
      defoverridable [call: 2]

      def call(conn, opts) do
        try do
          super(conn, opts)
        rescue
          exception ->
            stacktrace = System.stacktrace
            user = if @user_fn, do: unquote(@user_fn).user.(conn)
            IO.puts "user is #{user}"
            Raygun.report_plug(conn, stacktrace, exception, env: Atom.to_string(Mix.env), user: user)
            reraise exception, stacktrace
        end
      end
    end
  end
end
