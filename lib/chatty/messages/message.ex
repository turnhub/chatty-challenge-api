defmodule Chatty.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chatty.Chats.Chat

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :text, :string

    belongs_to :chat, Chat

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text, :chat_id])
    |> validate_required([:text, :chat_id])
  end
end
