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
        IO.puts "env is:"
        IO.inspect env

    quote location: :keep do
      defoverridable [call: 2]

      def call(conn, opts) do
        IO.puts "opts are:"
        IO.inspect opts
        try do
          super(conn, opts)
        rescue
          exception ->
            stacktrace = System.stacktrace
            IO.inspect opts
            if Keyword.has_key?(opts, :user) do
              user = opts.user.(conn)
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
