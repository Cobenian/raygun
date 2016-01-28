# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for third-
# party users, it should be done in your mix.exs file.

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]

# Sample configuration for sending logged errors to Raygun
# config :logger,
#   backends: [:console, Raygun]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

## Sample Raygun config
# config :raygun,
#     api_key: "<YOUR API KEY GOES HERE>",
#     tags: [:dev, :alpha],
#     system_user: %{
#       			identifier: "janedoe",
#       			isAnonymous: true,
#       			email: "janedoe@example.com",
#       			fullName: "Jane Doe",
#       			firstName: "Jane",
#       			uuid: "7f01cd5e-8f9b-4607-82b7-5465dcba31f0"
#     		  }
