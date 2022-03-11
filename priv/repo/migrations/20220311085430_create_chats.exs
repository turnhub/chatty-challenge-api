defmodule Chatty.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :from_name, :string
      add :fromNumber, :string

      add :user_id, references(:users, type: :binary_id), null: false

      timestamps()
    end
  end
end
