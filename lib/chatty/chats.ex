defmodule Chatty.Chats do
  import Ecto.Query
  alias Chatty.Chats.Chat
  alias Chatty.Messages.Message
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

  def list_chats_for_user_with_last_message(user) do
    ranking_query =
      from m in Message,
        select: %{id: m.id, row_number: over(row_number(), :chats_partition)},
        windows: [chats_partition: [partition_by: :chat_id, order_by: [desc: :inserted_at]]]

    last_messages_query =
      from m in Message,
        join: r in subquery(ranking_query),
        on: m.id == r.id and r.row_number <= 1

    chats_query =
      from c in Chat,
        where: c.user_id == ^user.id,
        order_by: [desc: c.inserted_at],
        preload: [messages: ^last_messages_query]

    Repo.all(chats_query)
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
end
