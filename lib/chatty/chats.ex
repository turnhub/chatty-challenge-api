defmodule Chatty.Chats do
  def list_chats() do
    [
      %{id: 1, title: "first chat"},
      %{id: 2, title: "second chat"},
      %{id: 3, title: "third chat"}
    ]
  end
end
