defmodule ChattyWeb.Schema do
  use Absinthe.Schema

  import_types(Absinthe.Type.Custom)
  import_types(ChattyWeb.Schema.AccountsTypes)
  import_types(ChattyWeb.Schema.ChatsTypes)

  alias ChattyWeb.Resolvers

  query do
    @desc "List all your chats, each of them has a preview of the last message in the chat."
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

    @desc "Send a message in a chat"
    field :send_message, type: :message do
      arg(:chat_id, non_null(:id))
      arg(:text, non_null(:string))
      resolve(&Resolvers.Chats.send_message/3)
    end
  end

  subscription do
    @desc "Subscribe to get notified whenever a new messages is sent/received in a chat"
    field :new_chat_message, :message do
      arg(:chat_id, non_null(:id))
      config(&Resolvers.Chats.new_chat_message_config/2)
    end

    @desc """
    Subscribe to get notified whenever one of your chats is updated (e.g. new message in the chat)
    or a new chat is created for your account.
    """
    field :chat_changed, :chat do
      config(&Resolvers.Chats.chat_changed_config/2)
      resolve(&Resolvers.Chats.chat_changed_resolver/3)
    end
  end
end
