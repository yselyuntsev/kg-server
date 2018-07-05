defmodule KeyGuard.Keys.KeyAccess.ValidatorTest do
  use KeyGuard.DataCase
  alias KeyGuard.Keys.KeyAccess
  alias KeyGuard.Keys.KeyAccess.Validator
  import KeyGuard.Factory

  setup do
    key = insert(:key)
    employee = insert(:employee)

    {:ok, key: key, employee: employee}
  end

  describe "create_changeset/2" do
    test "when all fields are valid", ctx do
      params = %{key_id: ctx.key.id, employee_id: ctx.employee.id, access_type: true}
      assert Validator.create_changeset(%KeyAccess{}, params).valid?
    end

    test "required fields presence" do
      required_fields = [:key_id, :employee_id, :access_type]
      changeset = Validator.create_changeset(%KeyAccess{}, %{})
      for field <- required_fields, do: assert("can't be blank" in errors_on(changeset)[field])
    end

    test "validate key_id and employee_id uniqueness" do
      key_access = insert(:key_access)
      params = %{"key_id" => key_access.key_id, "employee_id" => key_access.employee_id, "access_type" => true}

      assert {:error, changeset} = %KeyAccess{} |> Validator.create_changeset(params) |> Repo.insert()
      assert("has already been taken" in errors_on(changeset).key_id)
    end
  end

  describe "update_changeset/2" do
    setup do
      key_access = insert(:key_access)
      {:ok, key_access: key_access}
    end

    test "when all fields are valid", ctx do
      params = %{access_type: !ctx.key_access}
      assert Validator.update_changeset(ctx.key_access, params).valid?
    end

    test "required fields presence", ctx do
      required_fields = [:access_type]
      changeset = Validator.update_changeset(ctx.key_access, %{access_type: nil})
      for field <- required_fields, do: assert("can't be blank" in errors_on(changeset)[field])
    end
  end
end
