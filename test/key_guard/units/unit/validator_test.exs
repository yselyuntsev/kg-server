defmodule KeyGuard.Units.Unit.ValidatorTest do
  use KeyGuard.DataCase
  alias KeyGuard.TestUtils
  alias KeyGuard.Units.Unit
  alias KeyGuard.Units.Unit.Validator
  import KeyGuard.Factory

  describe "changeset/2" do
    setup do
      unit = insert(:unit)
      {:ok, unit: unit}
    end

    test "when all fields are valid", %{unit: unit} do
      assert Validator.changeset(%Unit{}, %{"name" => "Name", "parent_id" => unit.id}).valid?
    end

    test "required fields presence" do
      required_fields = [:name]
      changeset = Validator.changeset(%Unit{}, %{})
      for field <- required_fields, do: assert("can't be blank" in errors_on(changeset)[field])
    end

    test "validate name length" do
      changeset = Validator.changeset(%Unit{}, %{"name" => TestUtils.generate_string(256)})
      assert "should be at most 255 character(s)" in errors_on(changeset).name
    end

    test "validate parent_id foreign key constraint" do
      {:error, changeset} = Validator.changeset(%Unit{}, %{"name" => "Unit name", "parent_id" => -1}) |> Repo.insert()
      assert "does not exist" in errors_on(changeset).parent_id
    end
  end
end
