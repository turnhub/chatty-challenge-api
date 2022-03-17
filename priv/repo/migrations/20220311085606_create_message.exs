defmodule Chatty.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :direction, :string, null: false
      add :text, :text, null: false
      add :chat_id, references(:chats, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:chat_id, :inserted_at])
  end
end
