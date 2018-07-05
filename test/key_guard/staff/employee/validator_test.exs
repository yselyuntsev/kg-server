defmodule KeyGuard.Staff.Employee.ValidatorTest do
  use KeyGuard.DataCase
  alias KeyGuard.{TestUtils, Repo}
  alias KeyGuard.Staff.Employee
  alias KeyGuard.Staff.Employee.Validator
  import KeyGuard.Factory

  describe "changeset/2" do
    test "when all fields are valid" do
      params = params_for(:employee)
      assert Validator.changeset(%Employee{}, params).valid?
    end

    test "required fields presence" do
      required_fields = [:first_name, :last_name, :patronym, :card]
      changeset = Validator.changeset(%Employee{}, %{})
      for field <- required_fields, do: assert("can't be blank" in errors_on(changeset)[field])
    end

    test "validate card uniqueness" do
      employee = insert(:employee)
      params = params_for(:employee, card: employee.card)
      assert {:error, changeset} = %Employee{} |> Validator.changeset(params) |> Repo.insert()
      assert "has already been taken" in errors_on(changeset).card
    end

    test "validate first_name length" do
      changeset = Validator.changeset(%Employee{}, %{"first_name" => TestUtils.generate_string(256)})
      assert "should be at most 255 character(s)" in errors_on(changeset).first_name
    end

    test "validate last_name length" do
      changeset = Validator.changeset(%Employee{}, %{"last_name" => TestUtils.generate_string(256)})
      assert "should be at most 255 character(s)" in errors_on(changeset).last_name
    end

    test "validate patronym length" do
      changeset = Validator.changeset(%Employee{}, %{"patronym" => TestUtils.generate_string(256)})
      assert "should be at most 255 character(s)" in errors_on(changeset).patronym
    end

    test "validate encoded_photo length" do
      changeset = Validator.changeset(%Employee{}, %{"encoded_photo" => TestUtils.generate_string(50_001)})
      assert "should be at most 50000 character(s)" in errors_on(changeset).encoded_photo
    end
  end
end
