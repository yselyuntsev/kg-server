defmodule KeyGuard.StaffTest do
  use KeyGuard.DataCase
  alias KeyGuard.{Staff, TestUtils, Repo}
  alias KeyGuard.Staff.Employee
  import KeyGuard.Factory
  import Ecto.Query, only: [from: 2]

  @encoded_photo "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg=="

  setup do
    [unit1, unit2] = insert_pair(:unit)
    {:ok, unit1: unit1, unit2: unit2}
  end

  describe "all_employees/0" do
    setup _ctx do
      insert_list(5, :employee)
      :ok
    end

    test "return all employees" do
      employees = Staff.all_employees()
      assert [%Employee{} | _] = employees
      assert Enum.count(employees) == 5
    end
    
  end

  describe "find_employee/1" do
    test "finds an employee by given id" do
      employee_id = insert(:employee).id
      assert %Employee{id: ^employee_id} = Staff.find_employee(employee_id)
    end

    test "returns nil when employee with given id isn't exists" do
      assert Staff.find_employee(0) == nil
    end
  end

  describe "find_employee_by_card_number/1" do
    test "finds an employee by given card number" do
      employee = insert(:employee)
      employee_id = employee.id
      assert %Employee{id: ^employee_id} = Staff.find_employee_by_card_number(employee.card)
    end

    test "returns nil when employee with given card number isn't exists" do
      assert Staff.find_employee_by_card_number("fake") == nil
    end
  end

  describe "create_employee/1" do
    test "with valid params", ctx do
      params = %{
        "first_name" => "Bruce",
        "last_name" => "Wayne",
        "patronym" => "The batman",
        "card" => "super-unique-card-number",
        "encoded_photo" => @encoded_photo,
        # Add -1 to check that invalid ids will be filtered
        "unit_ids" => [ctx.unit1.id, ctx.unit2.id, -1]
      }

      assert {:ok, %Employee{} = employee} = Staff.create_employee(params)
      assert employee.first_name == params["first_name"]
      assert employee.last_name == params["last_name"]
      assert employee.patronym == params["patronym"]
      assert employee.card == params["card"]
      assert employee.encoded_photo == params["encoded_photo"]

      assert_employee_associated_with_units(employee, [ctx.unit1, ctx.unit2])
    end

    test "with invalid params" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_employee(%{})
      assert [] = Repo.all(Employee)
    end

    test "it's possible to create an employee without associated units" do
      params = %{
        "first_name" => "Bruce",
        "last_name" => "Wayne",
        "patronym" => "The batman",
        "card" => "super-unique-card-number",
        "encoded_photo" => @encoded_photo
      }

      assert {:ok, %Employee{} = employee} = Staff.create_employee(params)
      assert_employee_associated_with_units(employee, [])
    end
  end

  describe "update_employee/2" do
    setup ctx do
      employee = insert(:employee, encoded_photo: nil)
      TestUtils.associate_employee_with_units(employee, [ctx.unit1])
      [employee: employee]
    end

    test "with valid params", ctx do
      params = %{
        "first_name" => "Peter",
        "last_name" => "Parker",
        "patronym" => "The spiderman",
        "card" => "new-super-unique-card-number",
        "encoded_photo" => @encoded_photo,
        "unit_ids" => [ctx.unit2.id]
      }

      assert_employee_associated_with_units(ctx.employee, [ctx.unit1])

      assert {:ok, %Employee{} = updated_employee} = Staff.update_employee(ctx.employee, params)
      assert updated_employee.first_name == params["first_name"]
      assert updated_employee.last_name == params["last_name"]
      assert updated_employee.patronym == params["patronym"]
      assert updated_employee.card == params["card"]
      assert updated_employee.encoded_photo == params["encoded_photo"]

      assert_employee_associated_with_units(updated_employee, [ctx.unit2])
    end

    test "with invalid params", ctx do
      assert {:error, %Ecto.Changeset{}} = Staff.update_employee(ctx.employee, %{"first_name" => nil})
      assert Repo.get(Employee, ctx.employee.id).first_name == ctx.employee.first_name
      assert_employee_associated_with_units(ctx.employee, [ctx.unit1])
    end

    test "it's possible to update an employee without associated units", ctx do
      assert_employee_associated_with_units(ctx.employee, [ctx.unit1])
      assert {:ok, %Employee{} = updated_employee} = Staff.update_employee(ctx.employee, %{"first_name" => "Peter"})
      assert_employee_associated_with_units(updated_employee, [])
    end
  end

  describe "delete_employee!/1" do
    test "delete an employee" do
      employee = insert(:employee)
      employee_id = employee.id

      assert %Employee{id: ^employee_id} = Staff.delete_employee!(employee)
      refute Repo.get(Employee, employee_id)
    end
  end

  defp assert_employee_associated_with_units(employee, units) do
    unit_ids = Enum.map(units, & &1.id)

    associations_count =
      from(e in "employee_units", where: e.unit_id in ^unit_ids and e.employee_id == ^employee.id, select: count(e.id))
      |> Repo.one!()

    assert Enum.count(unit_ids) == associations_count
  end
end
