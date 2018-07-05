defmodule KeyGuard.AdminTest do
  use KeyGuard.DataCase
  alias KeyGuard.Admin
  alias KeyGuard.Admin.User
  alias KeyGuard.Repo
  import KeyGuard.Factory

  describe "create_user/2" do
    setup do
      user = insert(:user, role: User.role(:superadmin))
      {:ok, user: user}
    end

    test "with valid params", %{user: user} do
      params = %{"username" => "neW-USeR", "password" => "password", "role" => User.role(:admin)}

      assert {:ok, %User{} = created_user} = Admin.create_user(params, user)
      assert created_user.username == String.downcase(params["username"])
      assert created_user.role == params["role"]

      assert is_binary(created_user.token)
      refute created_user.token == ""

      assert Comeonin.Bcrypt.checkpw(params["password"], created_user.hashed_password)
    end

    test "with invalid params", %{user: user} do
      params = %{"username" => "username"}

      assert {:error, %Ecto.Changeset{}} = Admin.create_user(params, user)
      refute Repo.get_by(User, username: params["username"])
    end

    test "user can create only users with role less than his own" do
      user = insert(:user, role: User.role(:admin))
      params = %{"username" => "username", "password" => "password", "role" => User.role(:admin)}

      assert {:error, :role_not_allowed} = Admin.create_user(params, user)
      refute Repo.get_by(User, username: params["username"])
    end
  end

  describe "authenticate_user/1" do
    setup do
      user = insert(:user)
      {:ok, user: user}
    end

    test "returns user's token after successful authentication", %{user: %User{token: token} = user} do
      params = %{"username" => user.username, "password" => "password"}
      assert {:ok, ^token} = Admin.authenticate_user(params)
    end

    test "returns an error when user is exists, but password is incorrect", %{user: user} do
      params = %{"username" => user.username, "password" => "wrong-password"}
      assert {:error, :wrong_params} = Admin.authenticate_user(params)
    end

    test "returns an error when user is not exits" do
      params = %{"username" => "fakeusername", "password" => "password"}
      assert {:error, :wrong_params} = Admin.authenticate_user(params)
    end
  end
end
