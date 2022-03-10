defmodule ChattyWeb.Schema do
  use Absinthe.Schema

  import_types(ChattyWeb.Schema.AccountsTypes)
  import_types(ChattyWeb.Schema.ChatsTypes)

  alias ChattyWeb.Resolvers

  query do
    @desc "Get all chats"
    field :chats, list_of(:chat) do
      resolve(&Resolvers.Chats.list_chats/3)
    end
  end

  mutation do
    @desc "Log ing"
    field :login, type: :account do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&Resolvers.Accounts.login/3)
    end
  end
end
