ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Epitest.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Epitest.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Epitest.Repo)

