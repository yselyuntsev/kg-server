defmodule KeyGuardWeb.UserViewTest do
  use KeyGuardWeb.ConnCase
  alias KeyGuardWeb.{UserView, ErrorHelpers}
  alias KeyGuard.Admin.User
  alias KeyGuard.Admin.User.Validator, as: KeyValidator
  import KeyGuard.Factory

  describe "render manage.json" do
    setup do
      user = insert(:user)
      changeset = KeyValidator.changeset(%User{}, %{})
      {:ok, user: user, changeset: changeset}
    end

    test "successful response", %{user: user} do
      assert UserView.render("manage.json", user: user) == %{
               "data" => %{"user" => %{"id" => user.id, "username" => user.username, "role" => user.role}}
             }
    end

    test "validation error response", %{changeset: changeset} do
      assert UserView.render("manage.json", changeset: changeset) == ErrorHelpers.format_validation_errors(changeset)
    end

    test "role not allowed error response" do
      assert UserView.render("manage.json", error: :role_not_allowed) == %{
               "error" => %{"message" => "Role not allowed"}
             }
    end
  end

  describe "render authenticate.json" do
    setup do
      user = insert(:user)
      {:ok, user: user}
    end

    test "successful response", ctx do
      assert UserView.render("authenticate.json", %{token: ctx.user.token}) == %{"data" => %{"token" => ctx.user.token}}
    end

    test "error response" do
      assert UserView.render("authenticate.json", %{error: :wrong_params}) == %{
               "error" => %{"message" => "Invalid username or password"}
             }
    end
  end
end
