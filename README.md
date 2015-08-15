Raygun
======

THIS IS AN ALPHA RELEASE. IT IS NOT FUNCTIONAL YET!

Much of the functionality described below is intended functionality, it has
not been developed yet.

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

You can OPTIONALLY add tags as well. These tags will be sent with every reported
error.

```elixir
config :raygun,
    api_key: "<INSERT YOUR API KEY HERE>",
    tags: ["tag1", "tag2"]
```

## Usage

There are three different ways you can use Raygun. All three ways may be combined,
but you _may_ send the same message multiple times if you do that.

### By HTTP Status Code in Phoenix

By default, any response that has a 500 Internal Server Error HTTP status code
will send a message to Raygun.

```elixir
defmodule YourApp.Router do
  use Phoenix.Router
  use Raygun

  # ...
end
```

If however, you would like to explicitly list all the status codes to send to
Raygun that can be done by adding a list of status codes after the plug definition.
Note that either individual status codes or ranges of status codes may be used.

```elixir
defmodule YourApp.Router do
  use Phoenix.Router
  use Raygun, [404, 500..599]

  # ...
end
```

### Via the Logger

Any exception logged with automatically be sent to Raygun.

### Any Elixir code

  # Start our Raygun application
  Raygun.start

  # Report an exception.
  ```elixir
  try do
    :foo = :bar
  rescue
    exception ->
      stacktrace = System.stacktrace
      Raygun.report(stacktrace, exception)
  end
  ```

## License

[LICENSE](LICENSE)
