defmodule ChattyWeb.Resolvers.Accounts do
  alias Chatty.Accounts

  def login(_parent, _args, %{context: %{current_user: user}}) do
    {:error, "You are already logged in as #{user.email}"}
  end

  def login(_parent, %{email: email, password: password}, _resolution) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      token = Accounts.generate_user_session_token(user) |> Base.encode64()
      {:ok, %{email: email, token: token}}
    else
      {:error, "Invalid email or password"}
    end
  end
end
