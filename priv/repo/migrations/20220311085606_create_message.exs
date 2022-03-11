defmodule Chatty.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :string
      add :chat_id, references(:chats, type: :binary_id), null: false

      timestamps()
    end
  end
end
