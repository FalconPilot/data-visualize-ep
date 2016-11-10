# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :epitest,
  ecto_repos: [Epitest.Repo]

# Configures the endpoint
config :epitest, Epitest.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "LMrMbRBedStvMKnvSW7+uuVsCeaAiY4vEvpXeirEItkxnJJPKak2ywBQ3n8z9wpx",
  render_errors: [view: Epitest.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Epitest.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
