defmodule Chatty.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chatty.Chats` context.
  """

  @doc """
  Generate a chat.
  """
  def chat_fixture(attrs \\ %{}) do
    {:ok, chat} =
      attrs
      |> Enum.into(%{
        fromNumber: "some fromNumber",
        from_name: "some from_name"
      })
      |> Chatty.Chats.create_chat()

    chat
  end

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        text: "some text"
      })
      |> Chatty.Chats.create_message()

    message
  end
end
