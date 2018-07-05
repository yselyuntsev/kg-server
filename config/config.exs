# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :key_guard,
  ecto_repos: [KeyGuard.Repo]

# Configures the endpoint
config :key_guard, KeyGuardWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "a/aiX9NUbSnwVXhZnyAsFh1pCDtD9QhjyPBouZFRSwxGkmFoLKcNxO/nCc1lvYht",
  render_errors: [view: KeyGuardWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: KeyGuard.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
