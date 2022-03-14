defmodule ChattyWeb.Channels.UserSocket do
  @moduledoc """
  Phoenix socket used for GraphQL subscription only inside the bundled GraphiQL interface.
  Clients should not use this phoneix-specific socket for graphQL subscriptions, but rather
  ChattyWeb.Channels.GraphqlSocket, which implements the graphql standard protocl.
  """

  use Phoenix.Socket

  use Absinthe.Phoenix.Socket,
    schema: ChattyWeb.Schema

  alias Chatty.Accounts

  def connect(params, socket) do
    socket =
      Absinthe.Phoenix.Socket.put_options(socket,
        context: build_context(params)
      )

    {:ok, socket}
  end

  def id(_socket), do: nil

  defp build_context(params) do
    with "Bearer " <> token when is_binary(token) <- Map.get(params, "Authorization"),
         {:ok, token_decoded} <- Base.decode64(token),
         {:ok, current_user} <- authorize(token_decoded) do
      %{current_user: current_user}
    else
      _ -> %{}
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
