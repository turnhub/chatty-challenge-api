defmodule ChattyWeb.Schema.ChatsTypes do
  use Absinthe.Schema.Notation

  @desc "A chat is a collection of messages echanged with a contact"
  object :chat do
    field :id, non_null(:id)
    field :contact, non_null(:contact)
    field :last_message, :message
  end

  @desc "A text chat message"
  object :message do
    field :id, non_null(:id)
    field :direction, non_null(:message_direction)
    field :inserted_at, non_null(:naive_datetime)
    field :text, non_null(:string)
  end

  @desc "Contact with whom you are chatting"
  object :contact do
    field :name, non_null(:string)
    field :phone_number, non_null(:string)
  end

  @desc "The direction of a message"
  enum :message_direction do
    value(:inbound, description: "Received from contact")
    value(:outbound, description: "Sent to contact")
  end
end
