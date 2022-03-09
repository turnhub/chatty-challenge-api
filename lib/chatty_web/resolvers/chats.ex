defmodule ChattyWeb.Resolvers.Chats do
  def list_chats(_parent, _args, _resolution) do
    {:ok, Chatty.Chats.list_chats()}
  end
end
