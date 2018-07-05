defmodule KeyGuard.Keys.Key.ValidatorTest do
  use KeyGuard.DataCase
  alias KeyGuard.{Repo, TestUtils}
  alias KeyGuard.Keys.Key
  alias KeyGuard.Keys.Key.Validator
  import KeyGuard.Factory

  describe "create_changeset/2" do
    test "when all fields are valid" do
      params = params_for(:key)
      assert Validator.create_changeset(%Key{}, params).valid?
    end

    test "required fields presence" do
      required_fields = [:id, :name, :color]
      changeset = Validator.create_changeset(%Key{}, %{})
      for field <- required_fields, do: assert("can't be blank" in errors_on(changeset)[field])
    end

    test "validate id uniqueness" do
      key = insert(:key)
      params = params_for(:key, id: key.id)
      assert {:error, changeset} = %Key{} |> Validator.create_changeset(params) |> Repo.insert()
      assert "has already been taken" in errors_on(changeset).id
    end

    test "validate name uniqueness" do
      key = insert(:key)
      params = params_for(:key, name: key.name)
      assert {:error, changeset} = %Key{} |> Validator.create_changeset(params) |> Repo.insert()
      assert "has already been taken" in errors_on(changeset).name
    end

    test "validate name length" do
      changeset = Validator.create_changeset(%Key{}, %{name: TestUtils.generate_string(51)})
      assert "should be at most 50 character(s)" in errors_on(changeset).name
    end

    test "validate id length" do
      changeset = Validator.create_changeset(%Key{}, %{id: TestUtils.generate_string(151)})
      assert "should be at most 150 character(s)" in errors_on(changeset).id
    end
  end

  describe "update_changeset/2" do
    setup do
      key = insert(:key)
      {:ok, key: key}
    end

    test "when all fields are valid", %{key: key} do
      assert Validator.update_changeset(key, %{"name" => "new-name", "extra" => "new extra", "color" => "new-color"}).valid?
    end

    test "required fields presence", %{key: key} do
      required_fields = [:name, :color]
      changeset = Validator.update_changeset(key, %{name: nil, color: nil})
      for field <- required_fields, do: assert("can't be blank" in errors_on(changeset)[field])
    end

    test "validate name uniqueness", %{key: key} do
      key2 = insert(:key)
      assert {:error, changeset} = key |> Validator.update_changeset(%{"name" => key2.name}) |> Repo.update()
      assert "has already been taken" in errors_on(changeset).name
    end
  end
end
