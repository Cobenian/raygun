Raygun
======

Capture and send errors in your Elixir applications to Raygun for centralized
bug reporting.

## Install

Add the dependency to your mix.exs file.

```elixir
def deps do  
  [{:raygun, "~> 0.1.1"}]
end
```

Add Raygun, httpoison and tzdata to the list of applications.

```elixir
def application do
  [applications: [:logger, :raygun, :httpoison, :tzdata]
end
```

## Configuration

Add the following entry to your config/config.exs file.

```elixir
config :raygun,
    api_key: "<INSERT YOUR API KEY HERE>"
```

You can *OPTIONALLY* add other configuration options as well. They will be sent
with every error.
* tags: list of metadata strings
* url: a reference URL
* client_name: the name of the application as you want it to appear in Raygun
* client_version: the version of the application as you want it to appear in Raygun

```elixir
config :raygun,
    api_key: "<INSERT YOUR API KEY HERE>",
    tags: ["tag1", "tag2"],
    url: "http://docs.myapp.example.com",
    client_name: "MyApp",
    client_version: "2.3.4"
```

## Usage

There are three different ways you can use Raygun. All three ways may be combined,
but you _might_ send the same message multiple times if you do that.

### Via Plug in Phoenix

Add the plug to your router:

```elixir
defmodule YourApp.Router do
  use Phoenix.Router
  use Raygun.Plug

  # ...
end
```

You can also provide a function that takes a Plug Conn and returns a map with
information about the logged in user.

```elixir
defmodule YourApp.Router do
  use Phoenix.Router
  use Raygun.Plug, user: fn(conn) ->
    %{
      identifier: "<user id>",
      isAnonymous: false, # false if logged in, true if not logged in
      email: "email@example.com",
      fullName: "John Doe",
      firstName: "John",
      uuid: "<uuid>"
    }
  end

  # ...
end
```

### Via the Logger

Any error logged with automatically be sent to Raygun.

Configure the Logger to use the Raygun backend. You can do this programmatically

  ```elixir
  Logger.add_backend(Raygun.Logger)
  ```

or via configuration by adding Raygun as a backend in config/config.exs:

  ```elixir
  config :logger,
    backends: [:console, Raygun.Logger]
  ```

Any messages logged at :error level will be automatically sent to Raygun.

If you would like messages to be associated with a system user then add the
following configuration to config/config.exs:

  ```elixir
  config :raygun,
      system_user: %{
        			identifier: "myuserid",
        			isAnonymous: true,
        			email: "myuserid@example.com",
        			fullName: "Jane Doe",
        			firstName: "Jane",
        			uuid: "b07eb66c-9055-4847-a173-881b77cdc83e"
      		  }
  ```

### Any Elixir code

Start our Raygun application (if you did not configure it as an application
in mix.exs)

```elixir
Raygun.start
```

Send a string message to Raygun:

```elixir
Raygun.report_message "Oh noes."
```

Report an exception programmatically. Be sure that System.stacktrace will be
the correct stack trace!

```elixir
try do
  :foo = :bar
rescue
  exception -> Raygun.report_exception(exception)
end
```

Or capture the stacktrace explicitly yourself and pass it to Raygun.

```elixir
try do
  :foo = :bar
rescue
  exception ->
    stacktrace = System.stacktrace
    Raygun.report_stacktrace(stacktrace, exception)
end
```  

Both forms allow some custom context to be passed as an optional final
parameters as a Map. This will appear as 'userCustomData' under the custom
tab in Raygun's web interface.

```elixir
try do
  :foo = :bar
rescue
  exception ->
    Raygun.report_stacktrace(System.stacktrace, exception, %{env: Mix.env})
end
```

## License

[LICENSE](LICENSE)
