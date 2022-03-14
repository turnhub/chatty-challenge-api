defmodule Chatty.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chatty.Accounts.User
  alias Chatty.Chats.Message

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chats" do
    field :from_number, :string
    field :from_name, :string

    has_many :messages, Message
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:from_name, :from_number, :user_id])
    |> validate_required([:from_name, :from_number, :user_id])
  end
end
