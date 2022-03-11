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
end
