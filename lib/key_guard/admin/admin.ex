defmodule KeyGuard.Admin do
  @moduledoc "Admin context functions."

  alias KeyGuard.Repo
  alias KeyGuard.Admin.User
  alias KeyGuard.Admin.User.Validator, as: UserValidator

  defdelegate roles(), to: User
  defdelegate role(role_name), to: User

  @doc """
  Creates a new user.
  The function takes `params` and `current_user` args and returns one of:
    * `{:ok, created_user}` - when user was successfully crated;
    * `{:error, :role_not_allowed}` - when `current_user` role is smaller or equals than created user role;
    * `{:error, changeset}` - when some params are invalid.

  Note that user can create new users only when the role of new user less that his own role.
  I.e. `superadmin` can create both `admin` and `moderator`, `admin` can create `moderator` only
  and `moderator` isn't able to create new users.

  ### Example:
      current_user = Repo.get(User, id)
      params = %{"username" => "username", "password" => "password", "role" => User.role(:moderator)}
      Admin.create_user(params, current_user)
  """
  @spec create_user(map, %User{}) :: {:ok, %User{}} | {:error, Ecto.Changeset.t()} | {:error, :role_not_allowed}
  def create_user(params, current_user) do
    updated_params = params |> put_hashed_password() |> put_auth_token()
    changeset = UserValidator.changeset(%User{}, updated_params)

    if role_allowed?(changeset.changes[:role], current_user.role),
      do: Repo.insert(changeset),
      else: {:error, :role_not_allowed}
  end

  @doc """
  Authenticates an user.
  The function takes 'params' argument and returns one of:
    * `{:ok, token}` - when user was successfully authenticated;
    * `{:error, :wrong_params}` - when user with given username is not exists or when password is incorrect.

  ### Example:
      params = %{"username" => "admin", "password" => "super-secure-password"}
      Admin.authenticate_user(params)
  """
  @spec authenticate_user(map) :: {:ok, String.t()} | {:error, :wrong_params}
  def authenticate_user(params) do
    user = Repo.get_by(User, username: params["username"])
    if user && correct_password?(user, params["password"]), do: {:ok, user.token}, else: {:error, :wrong_params}
  end

  defp put_hashed_password(%{"password" => password} = params) when password in [nil, ""], do: params

  defp put_hashed_password(%{"password" => password} = params) do
    hashed_password = Comeonin.Bcrypt.hashpwsalt(password)
    Map.put(params, "hashed_password", hashed_password)
  end

  defp put_hashed_password(params), do: params

  defp put_auth_token(params) do
    token_length = 15
    token = :crypto.strong_rand_bytes(token_length) |> Base.url_encode64() |> binary_part(0, token_length)

    Map.put(params, "token", token)
  end

  defp role_allowed?(role, current_user_role) when current_user_role > role, do: true
  defp role_allowed?(nil, _), do: true
  defp role_allowed?(_, _), do: false

  defp correct_password?(%User{hashed_password: hashed_password}, password),
    do: Comeonin.Bcrypt.checkpw(password, hashed_password)
end
