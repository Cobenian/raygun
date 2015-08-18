defmodule Raygun.Plug do
  @moduledoc """
  This plug is designed to wrap calls in a router (commonly in Phoenix) so that
  any exceptions will be sent to Raygun.
  """

  defmacro __using__(_env) do
    quote location: :keep do
      @before_compile Raygun.Plug
    end
  end

  @doc """
  Whenever an error occurs, capture the stacktrace and exception to send to Raygun.
  """
  defmacro __before_compile__(env) do
    quote location: :keep do
      defoverridable [call: 2]

      def call(conn, opts) do
        IO.puts "opts are:"
        IO.inspect opts
        IO.puts "env is:"
        ev = unquote(env)
        IO.inspect ev
        try do
          super(conn, opts)
        rescue
          exception ->
            stacktrace = System.stacktrace
            IO.inspect opts
            if Keyword.has_key?(ev, :user) do
              user = ev.user.(conn)
            else
              user = nil
            end
            IO.puts "user is #{user}"
            Raygun.report_plug(conn, stacktrace, exception, env: Atom.to_string(Mix.env), user: user)
            reraise exception, stacktrace
        end
      end
    end
  end
end
