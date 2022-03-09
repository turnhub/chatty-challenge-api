defmodule ChattyWeb.Schema.ChatsTypes do
  use Absinthe.Schema.Notation

  object :chat do
    field :id, :id
    field :title, :string
  end
end
