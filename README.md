Raygun
======

THIS IS AN **ALPHA** RELEASE. IT IS NOT FUNCTIONAL YET!

## Install

Add the dependency to your mix.exs file.

```elixir
def deps do  
  [{:raygun, "~> 0.0.1"}]
end
```

Add Raygun to the list of applications.

```elixir
def application do
  [applications: [:logger, :raygun]
end
```

## Configuration

Add the following entry to your config/config.exs file.

```elixir
config :raygun,
    api_key: "<INSERT YOUR API KEY HERE>"
```

You can *OPTIONALLY* add tags as well. These tags will be sent with every
reported error.

```elixir
config :raygun,
    api_key: "<INSERT YOUR API KEY HERE>",
    tags: ["tag1", "tag2"]
```

## Usage

There are three different ways you can use Raygun. All three ways may be combined,
but you _may_ send the same message multiple times if you do that.

### By Plug in Phoenix

Add the plug to your router:

```elixir
defmodule YourApp.Router do
  use Phoenix.Router
  use Raygun.Plug

  # ...
end
```

We are still considering a few options for detecting the currently logged in
user. Since nearly every application handles it differently we will most
likely provide a configuration option that takes a callback. The function you
provide will be passed the Plug Conn state.

### Via the Logger

Any error logged with automatically be sent to Raygun.

Configure the Logger to use the Raygun backend. You can do this programmatically

  ```elixir
  Logger.add_backend(Raygun)
  ```

or via configuration by adding Raygun as a backend in config/config.exs:

  ```elixir
  config :logger,
    backends: [:console, Raygun]
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

Report an exception programmatically. Be sure that System.stacktrace will be
the correct stack trace!

```elixir
try do
  :foo = :bar
rescue
  exception -> Raygun.report(exception)
end
```

Or capture the stacktrace explicitly yourself and pass it to Raygun.

```elixir
try do
  :foo = :bar
rescue
  exception ->
    stacktrace = System.stacktrace
    Raygun.report(stacktrace, exception)
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
    Raygun.report(System.stacktrace, exception, %{env: Mix.env})
end
```

## License

[LICENSE](LICENSE)
