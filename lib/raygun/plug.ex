defmodule Raygun.Plug.State do
  @moduledoc """
  This wraps an agent used at compile time to save a function passed in by the
  router so it can be used before compiling the remaining macros.
  """

  @mix_env Atom.to_string(Mix.env())

  def start_link do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def set(value) do
    Agent.update(__MODULE__, fn _x -> value end)
  end

  def get do
    Agent.get(__MODULE__, fn x -> x end)
  end
end

defmodule Raygun.Plug do
  @moduledoc """
  This plug is designed to wrap calls in a router (commonly in Phoenix) so that
  any exceptions will be sent to Raygun.
  """

  defmacro __using__(opts) do
    Raygun.Plug.State.start_link()
    Raygun.Plug.State.set(opts)

    quote location: :keep do
      @before_compile Raygun.Plug
    end
  end

  def get_user(conn, env) do
    if env do
      Keyword.get(env, :user).(conn)
    end
  end

  @doc """
  Whenever an error occurs, capture the stacktrace and exception to send to Raygun.
  """
  defmacro __before_compile__(_env) do
    quote location: :keep do
      defoverridable call: 2

      @app_using_raygun_version Mix.Project.config()[:version]

      def call(conn, opts) do
        try do
          super(conn, opts)
        rescue
          exception ->
            stacktrace = System.stacktrace()

            Raygun.report_plug(conn, stacktrace, exception,
              vsn: Raygun.Util.get_key(:raygun, :vsn) |> List.to_string(),
              version: @app_using_raygun_version,
              user: Raygun.Plug.get_user(conn, unquote(Raygun.Plug.State.get()))
            )

            reraise exception, stacktrace
        end
      end
    end
  end
end
