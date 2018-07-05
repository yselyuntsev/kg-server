defmodule KeyGuardWeb.EmployeeView do
  use KeyGuardWeb, :view

  def render("index.json", %{employees: employees}), do: %{"data" => %{"employees" => Enum.map(employees, &normalize_employee/1)}}

  def render("manage.json", %{employee: nil}), do: employee_not_exists()

  def render("manage.json", %{employee: employee}), do: employee_info(employee)

  def render("manage.json", %{changeset: changeset}), do: format_validation_errors(changeset)

  def render("delete.json", %{employee: nil}), do: employee_not_exists()

  def render("delete.json", %{employee: employee}),
    do: %{"data" => %{"id" => employee.id, "message" => "Employee was successfully deleted"}}

  def render("find_by_card_number.json", %{employee: nil}),
    do: %{"error" => %{"message" => "Employee with given card number is not exists"}}

  def render("find_by_card_number.json", %{employee: employee}), do: %{"data" => %{"employee" => normalize_employee(employee)}}

  defp employee_info(employee) do
    %{
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
  end

  defp employee_not_exists(), do: %{"error" => %{"message" => "Employee with given ID is not exists"}}

  defp normalize_employee(employee) do
    %{
      "id" => employee.id,
      "first_name" => employee.first_name,
      "last_name" => employee.last_name,
      "patronym" => employee.patronym,
      "card" => employee.card,
      "encoded_photo" => employee.encoded_photo,
      "unit_ids" => Enum.map(employee.units, &normalize_unit/1)
    }
  end
  
  defp normalize_unit(unit), do: unit.id
end
