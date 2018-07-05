defmodule KeyGuard.Admin.User.Validator do
  @moduledoc "User's validation funtions."

  alias KeyGuard.Admin.User
  import Ecto.Changeset

  @required_fields [:username, :password, :token, :hashed_password, :role]

  @spec changeset(%KeyGuard.Admin.User{}, map) :: Ecto.Changeset.t()
  def changeset(user, params \\ %{}) do
    user
    |> cast(params, @required_fields)
    |> update_change(:username, &String.downcase/1)
    |> validate_required(@required_fields)
    |> validate_length(:username, max: 50)
    |> validate_format(:username, ~r"^[a-z0-9_\-]+$")
    |> unique_constraint(:username, name: :users_username_index)
    |> validate_length(:password, min: 8, max: 150)
    |> validate_inclusion(:role, User.roles() |> Map.values())
  end
end
