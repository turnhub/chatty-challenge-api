defmodule Chatty.Chats.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chatty.Chats.Chat

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :direction, Ecto.Enum, values: [:inbound, :outbound]
    field :text, :string

    belongs_to :chat, Chat

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:direction, :text, :chat_id])
    |> validate_required([:direction, :text, :chat_id])
  end
end
