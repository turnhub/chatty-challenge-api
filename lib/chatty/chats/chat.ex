defmodule Chatty.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chatty.Messages.Message

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chats" do
    field :fromNumber, :string
    field :from_name, :string

    has_many :messages, Message

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:from_name, :fromNumber])
    |> validate_required([:from_name, :fromNumber])
  end
end