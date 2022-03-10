defmodule ChattyWeb.Context do
  @behaviour Plug

  import Plug.Conn
  alias Chatty.Accounts

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  @doc """
  Return the current user context based on the authorization header
  """
  def build_context(conn) do
    with ["Bearer " <> token] when is_binary(token) <- get_req_header(conn, "authorization"),
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
