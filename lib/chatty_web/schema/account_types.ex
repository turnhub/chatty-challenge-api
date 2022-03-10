defmodule ChattyWeb.Schema.AccountsTypes do
  use Absinthe.Schema.Notation

  object :account do
    field :email, non_null(:string)
    field :token, non_null(:string)
  end
end
