defmodule ChattyWeb.Resolvers.Chats do
  def list_chats(_parent, _args, %{context: %{current_user: user}}) do
    {:ok, Chatty.Chats.list_chats_for_user(user)}
  end

  def list_chats(_parent, _args, _resolution) do
    {:error, "You are not logged in"}
  end
end
