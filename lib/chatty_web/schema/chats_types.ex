defmodule ChattyWeb.Schema.ChatsTypes do
  use Absinthe.Schema.Notation

  object :chat do
    field :id, non_null(:id)
    field :from_name, non_null(:string)
    field :from_number, non_null(:string)
  end
end
