defmodule Chatty.Chats do
  import Ecto.Query
  alias Chatty.Accounts.User
  alias Chatty.Chats.Chat
  alias Chatty.Chats.Message
  alias Chatty.Repo

  @doc """
  Returns the list of chats.

  ## Examples

      iex> list_chats()
      [%Chat{}, ...]

  """
  def list_chats do
    Chat
    |> Repo.all()
  end

  def list_chats_for_user(user) do
    chats_query =
      from c in Chat,
        where: c.user_id == ^user.id,
        order_by: [desc: c.inserted_at]

    Repo.all(chats_query)
  end

  @recent_chat_messages_to_preload 1
  def list_chats_for_user_with_last_message(user) do
    # Window-based preload as per the final example in
    # https://hexdocs.pm/ecto/Ecto.Query.html#preload/3-preload-queries
    last_messages_per_chat_query =
      from m in Message,
        select: %{id: m.id, row_number: over(row_number(), :chats_partition)},
        windows: [chats_partition: [partition_by: :chat_id, order_by: [desc: :inserted_at]]]

    last_messages_query =
      from m in Message,
        join: r in subquery(last_messages_per_chat_query),
        on: m.id == r.id and r.row_number <= @recent_chat_messages_to_preload

    chats_query =
      from c in Chat,
        where: c.user_id == ^user.id,
        order_by: [desc: c.inserted_at],
        preload: [messages: ^last_messages_query]

    Repo.all(chats_query)
  end

  def get_user_chat_with_last_message(chat_id) do
    last_messages_query =
      from m in Message, order_by: [desc: :inserted_at], limit: @recent_chat_messages_to_preload

    chat_query =
      from c in Chat,
        where: c.id == ^chat_id,
        preload: [messages: ^last_messages_query]

    Repo.one(chat_query)
  end

  @doc """
  Gets a single chat.

  Raises `Ecto.NoResultsError` if the Chat does not exist.

  ## Examples

      iex> get_chat!(123)
      %Chat{}

      iex> get_chat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat!(id), do: Repo.get!(Chat, id)

  def get_chat(id), do: Repo.get(Chat, id)

  @doc """
  Creates a chat.

  ## Examples

      iex> create_chat(%{field: value})
      {:ok, %Chat{}}

      iex> create_chat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chat.

  ## Examples

      iex> update_chat(chat, %{field: new_value})
      {:ok, %Chat{}}

      iex> update_chat(chat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat(%Chat{} = chat, attrs) do
    chat
    |> Chat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chat.

  ## Examples

      iex> delete_chat(chat)
      {:ok, %Chat{}}

      iex> delete_chat(chat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat(%Chat{} = chat) do
    Repo.delete(chat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat changes.

  ## Examples

      iex> change_chat(chat)
      %Ecto.Changeset{data: %Chat{}}

  """
  def change_chat(%Chat{} = chat, attrs \\ %{}) do
    Chat.changeset(chat, attrs)
  end

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  def list_chat_messages(chat_id) do
    Message
    |> where(chat_id: ^chat_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    insert_result =
      %Message{}
      |> Message.changeset(attrs)
      |> Repo.insert()

    with {:ok, message} <- insert_result do
      %Message{chat: %Chat{id: chat_id, user: %User{id: user_id}}} =
        Repo.preload(message, chat: :user)

      Absinthe.Subscription.publish(ChattyWeb.Endpoint, message, new_chat_message: message.chat_id)

      Absinthe.Subscription.publish(ChattyWeb.Endpoint, chat_id, chat_changed: user_id)

      {:ok, message}
    end
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
