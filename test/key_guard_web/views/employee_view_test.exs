defmodule KeyGuardWeb.EmployeeViewTest do
  use KeyGuardWeb.ConnCase
  alias KeyGuardWeb.{EmployeeView, ErrorHelpers}
  alias KeyGuard.TestUtils
  alias KeyGuard.Repo
  alias KeyGuard.Staff.Employee
  alias KeyGuard.Staff.Employee.Validator, as: EmployeeValidator
  import KeyGuard.Factory

  describe "render index.json" do
    setup do
      employee = insert(:employee)
      {:ok, employee: employee}
    end

    test "successful response", %{employee: employee} do
      employee = Repo.get(Employee, employee.id) |> Repo.preload(:units)
      assert EmployeeView.render("index.json", employees: [employee]) == %{
               "data" => %{
                 "employees" => [%{
                   "id" => employee.id,
                   "first_name" => employee.first_name,
                   "last_name" => employee.last_name,
                   "patronym" => employee.patronym,
                   "card" => employee.card,
                   "encoded_photo" => employee.encoded_photo,
                   "unit_ids" => employee.units
                 }]
               }
             }
    end
  end

  describe "render manage.json" do
    setup do
      employee = insert(:employee)
      changeset = EmployeeValidator.changeset(%Employee{}, %{"first_name" => TestUtils.generate_string(256)})

      {:ok, employee: employee, changeset: changeset}
    end

    test "successful response", %{employee: employee} do
      expected = %{
        "data" => %{
          "employee" => %{
            "id" => employee.id,
            "first_name" => employee.first_name,
            "last_name" => employee.last_name,
            "patronym" => employee.patronym,
            "card" => employee.card,
            "encoded_photo" => employee.encoded_photo
          }
        }
      }

      assert EmployeeView.render("manage.json", employee: employee) == expected
    end

    test "employee ID error response" do
      assert EmployeeView.render("manage.json", employee: nil) == %{
               "error" => %{"message" => "Employee with given ID is not exists"}
             }
    end

    test "validation error response", %{changeset: changeset} do
      assert EmployeeView.render("manage.json", changeset: changeset) ==
               ErrorHelpers.format_validation_errors(changeset)
    end
  end

  describe "render delete.json" do
    setup do
      employee = insert(:employee)
      {:ok, employee: employee}
    end

    test "successful response", %{employee: employee} do
      assert EmployeeView.render("delete.json", %{employee: employee}) == %{
               "data" => %{"id" => employee.id, "message" => "Employee was successfully deleted"}
             }
    end

    test "employee ID error response" do
      assert EmployeeView.render("delete.json", %{employee: nil}) == %{
               "error" => %{"message" => "Employee with given ID is not exists"}
             }
    end
  end

  describe "render find_by_card_number.json" do
    setup do
      employee = insert(:employee)
      {:ok, employee: employee}
    end

    test "successful response", %{employee: employee} do
      employee = Repo.get(Employee, employee.id) |> Repo.preload(:units)
      expected = %{
        "data" => %{
          "employee" => %{
            "id" => employee.id,
            "first_name" => employee.first_name,
            "last_name" => employee.last_name,
            "patronym" => employee.patronym,
            "card" => employee.card,
            "encoded_photo" => employee.encoded_photo,
            "unit_ids" => employee.units
          }
        }
      }

      assert EmployeeView.render("find_by_card_number.json", employee: employee) == expected
    end

    test "card id error response" do
      assert EmployeeView.render("find_by_card_number.json", employee: nil) == %{
               "error" => %{"message" => "Employee with given card number is not exists"}
             }
    end
  end
end
