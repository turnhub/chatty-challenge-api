# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :chatty,
  ecto_repos: [Chatty.Repo]

# Configures the endpoint
config :chatty, ChattyWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ChattyWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Chatty.PubSub,
  live_view: [signing_salt: "a+Kzc+Gf"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :chatty, Chatty.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Quantum jobs
config :chatty, Chatty.Scheduler,
  jobs: [
    # Every 30 seconds, generate more mock data
    {{:extended, "*/30 * * * * *"}, {Chatty.Mocks, :generate_more_mock_data, []}},
    # Every 1 hours, clean all data
    {"0 */1 * * *", {Chatty.Mocks, :clean_all_data, []}}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
