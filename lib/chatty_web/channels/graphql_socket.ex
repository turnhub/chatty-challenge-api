defmodule ChattyWeb.Channels.GraphqlSocket do
  @moduledoc """
  Socket that implements the standard websocket protocol and works out-of-the-box
  with the Apollo WS Link.
  """

  use Absinthe.GraphqlWS.Socket, schema: ChattyWeb.Schema

  alias Chatty.Accounts

  @impl true
  def handle_init(params, socket) do
    user = get_user(params)
    socket = assign_context(socket, current_user: user)
    {:ok, %{}, socket}
  end

  defp get_user(params) do
    with token when is_binary(token) <- Map.get(params, "token"),
         {:ok, token_decoded} <- Base.decode64(token),
         {:ok, current_user} <- authorize(token_decoded) do
      current_user
    else
      _ -> nil
    end
  end

  defp authorize(token) do
    user = Accounts.get_user_by_session_token(token)

    case user do
      nil -> {:error, "invalid authorization token"}
      user -> {:ok, user}
    end
  end
end
