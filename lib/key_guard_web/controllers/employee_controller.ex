defmodule KeyGuardWeb.EmployeeController do
  use KeyGuardWeb, :controller
  alias KeyGuard.Staff

  def index(conn, _params) do
    employees = Staff.all_employees()
    conn |> put_status(200) |> render("index.json", employees: employees)
  end

  def find_by_card_number(conn, params) do
    employee = Staff.find_employee_by_card_number(params["card_number"])

    if employee,
      do: conn |> put_status(200) |> render("find_by_card_number.json", employee: employee),
      else: conn |> put_status(404) |> render("find_by_card_number.json", employee: nil)
  end

  def create(conn, params) do
    case Staff.create_employee(params) do
      {:ok, created_employee} -> conn |> put_status(201) |> render("manage.json", employee: created_employee)
      {:error, changeset} -> conn |> put_status(400) |> render("manage.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => employee_id} = params) do
    with employee when not is_nil(employee) <- Staff.find_employee(employee_id),
         {:ok, updated_employee} <- Staff.update_employee(employee, params) do
      conn |> put_status(200) |> render("manage.json", employee: updated_employee)
    else
      nil -> conn |> put_status(404) |> render("manage.json", employee: nil)
      {:error, changeset} -> conn |> put_status(400) |> render("manage.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => employee_id}) do
    employee = Staff.find_employee(employee_id)

    if employee do
      Staff.delete_employee!(employee)
      conn |> put_status(200) |> render("delete.json", employee: employee)
    else
      conn |> put_status(404) |> render("delete.json", employee: employee)
    end
  end
end
