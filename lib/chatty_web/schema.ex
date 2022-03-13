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

  subscription do
    field :new_chat_message, :message do
      arg(:chat_id, non_null(:id))

      # The topic function is used to determine what topic a given subscription
      # cares about based on its arguments. You can think of it as a way to tell the
      # difference between
      # subscription {
      #   commentAdded(repoName: "absinthe-graphql/absinthe") { content }
      # }
      #
      # and
      #
      # subscription {
      #   commentAdded(repoName: "elixir-lang/elixir") { content }
      # }
      #
      # If needed, you can also provide a list of topics:
      #   {:ok, topic: ["absinthe-graphql/absinthe", "elixir-lang/elixir"]}
      config(fn args, _ ->
        {:ok, topic: args.chat_id}
      end)

      # this tells Absinthe to run any subscriptions with this field every time
      # the :submit_comment mutation happens.
      # It also has a topic function used to find what subscriptions care about
      # this particular comment
      trigger(:send_message,
        topic: fn message ->
          message.chat_id
        end
      )

      resolve(fn message, _, _ ->
        # this function is often not actually necessary, as the default resolver
        # for subscription functions will just do what we're doing here.
        # The point is, subscription resolvers receive whatever value triggers
        # the subscription, in our case a message.
        {:ok, message}
      end)
    end
  end
end
