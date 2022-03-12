defmodule ChattyWeb.Resolvers.Chats do
  alias Chatty.Chats

  def list_chats(_parent, _args, %{context: %{current_user: user}}) do
    chats =
      Chats.list_chats_for_user_with_last_message(user)
      |> build_chat_dtos()

    {:ok, chats}
  end

  def list_chats(_parent, _args, _resolution) do
    {:error, "You are not logged in"}
  end

  defp build_chat_dtos(chats) do
    for chat <- chats do
      last_message =
        case chat.messages do
          [m | _] -> m
          _ -> nil
        end

      Map.from_struct(chat)
      |> Map.put(:last_message, last_message)
      |> Map.put(:contact, %{name: chat.from_name, phone_number: chat.from_number})
    end
  end
end
