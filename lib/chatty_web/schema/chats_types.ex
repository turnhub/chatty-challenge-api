defmodule ChattyWeb.Schema.ChatsTypes do
  use Absinthe.Schema.Notation

  object :chat do
    field :id, non_null(:id)
    field :contact, non_null(:contact)
    field :last_message, :message
  end

  object :message do
    field :id, non_null(:id)
    field :inserted_at, non_null(:naive_datetime)
    field :text, non_null(:string)
  end

  object :contact do
    field :name, non_null(:string)
    field :phone_number, non_null(:string)
  end
end
