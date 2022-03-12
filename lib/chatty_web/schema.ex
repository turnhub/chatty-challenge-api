defmodule ChattyWeb.Schema do
  use Absinthe.Schema

  import_types(Absinthe.Type.Custom)
  import_types(ChattyWeb.Schema.AccountsTypes)
  import_types(ChattyWeb.Schema.ChatsTypes)

  alias ChattyWeb.Resolvers

  query do
    @desc "List all your chats"
    field :chats, list_of(:chat) do
      resolve(&Resolvers.Chats.list_chats/3)
    end

    @desc "List all messages for a chat"
    field :messages, list_of(:message) do
      arg(:chat_id, non_null(:id))
      resolve(&Resolvers.Chats.list_chat_messages/3)
    end
  end

  mutation do
    @desc "Log in with username and password and obtain an API access token"
    field :login, type: :account do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&Resolvers.Accounts.login/3)
    end

    @desc "Log in with username and password and obtain an API access token"
    field :send_message, type: :message do
      arg(:chat_id, non_null(:id))
      arg(:text, non_null(:string))
      resolve(&Resolvers.Chats.send_message/3)
    end
  end
end
