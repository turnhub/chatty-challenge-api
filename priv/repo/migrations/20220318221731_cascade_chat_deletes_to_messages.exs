defmodule Chatty.Repo.Migrations.CascadeChatDeletesToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      modify :chat_id, references(:chats, type: :binary_id, on_delete: :delete_all),
        null: false,
        from: references(:chats, type: :binary_id, on_delete: :nothing)
    end
  end
end
