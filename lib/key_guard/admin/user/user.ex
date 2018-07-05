defmodule KeyGuard.Admin.User do
  use Ecto.Schema

  schema "users" do
    field :username, :string
    field :hashed_password, :string
    field :token, :string
    field :role, :integer

    field :password, :string, virtual: true
  end

  # Note that the more role ID, the more privileges
  @spec roles() :: map
  def roles(), do: %{moderator: 0, admin: 1, superadmin: 2}

  @spec role(atom) :: integer
  def role(role_name), do: roles() |> Map.get(role_name)
end
