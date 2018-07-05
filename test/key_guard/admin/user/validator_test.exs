defmodule KeyGuard.Admin.User.ValidatorTest do
  use KeyGuard.DataCase
  alias KeyGuard.Admin.User
  alias KeyGuard.Admin.User.Validator
  alias KeyGuard.{Repo, TestUtils}
  import KeyGuard.Factory

  describe "changeset/2" do
    test "when all fields are valid" do
      params = params_for(:user)
      assert Validator.changeset(%User{}, params).valid?
    end

    test "required fields presence" do
      required_fields = [:username, :password, :hashed_password, :role, :token]
      changeset = Validator.changeset(%User{}, %{})
      for field <- required_fields, do: assert("can't be blank" in errors_on(changeset)[field])
    end

    test "validate username lenght" do
      changeset = Validator.changeset(%User{}, %{username: TestUtils.generate_string(51)})
      assert "should be at most 50 character(s)" in errors_on(changeset).username
    end

    test "validate username format" do
      for username <- ["with whitespace", "user.name", "скириллицей", "whitespaces   "] do
        changeset = Validator.changeset(%User{}, %{username: username})
        assert "has invalid format" in errors_on(changeset).username
      end

      for username <- ["username666", "user-name", "user_name", "123456"] do
        changeset = Validator.changeset(%User{}, %{username: username})
        refute changeset.errors[:username]
      end
    end

    test "validate username uniqueness" do
      user = insert(:user)
      params = params_for(:user, username: user.username)

      assert {:error, changeset} = Validator.changeset(%User{}, params) |> Repo.insert()
      assert "has already been taken" in errors_on(changeset).username
    end

    test "validate password lenght" do
      max_changeset = Validator.changeset(%User{}, %{password: TestUtils.generate_string(151)})
      assert "should be at most 150 character(s)" in errors_on(max_changeset).password

      min_changeset = Validator.changeset(%User{}, %{password: "12"})
      assert "should be at least 8 character(s)" in errors_on(min_changeset).password
    end

    test "validate role inclusion" do
      changeset = Validator.changeset(%User{}, %{role: -1})
      assert "is invalid" in errors_on(changeset).role
    end
  end
end
