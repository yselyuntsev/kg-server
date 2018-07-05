defmodule KeyGuardWeb.KeyAccessController do
  use KeyGuardWeb, :controller
  alias KeyGuard.Keys.Key
  alias KeyGuard.Staff.Employee
  alias KeyGuard.{Keys, Staff}

  def index(conn, _params) do
    keys_access = Keys.all_keys_access()
    conn |> put_status(200) |> render("index.json", keys_access: keys_access)
  end

  def show(conn, params) do
    keys_access = Keys.find_key_access_by_employee_id(params["employee_id"])
    conn |> put_status(200) |> render("show.json", keys_access: keys_access)
  end

  def create(conn, params) do
    key = Keys.find_key(params["key_id"])
    employee = Staff.find_employee(params["employee_id"])

    with {:key, %Key{}} <- {:key, key},
         {:employee, %Employee{}} <- {:employee, employee},
         {:ok, created_key_access} <- Keys.add_access_to_key(key, employee, params) do
      conn |> put_status(201) |> render("manage.json", key_access: created_key_access)
    else
      {:key, nil} -> conn |> put_status(404) |> render("manage.json", key: nil)
      {:employee, nil} -> conn |> put_status(404) |> render("manage.json", employee: nil)
      {:error, changeset} -> conn |> put_status(400) |> render("manage.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => key_access_id} = params) do
    with key_access when not is_nil(key_access) <- Keys.find_key_access(key_access_id),
         {:ok, updated_key_access} <- Keys.update_key_access(key_access, params) do
      conn |> put_status(200) |> render("manage.json", key_access: updated_key_access)
    else
      nil -> conn |> put_status(404) |> render("manage.json", key_access: nil)
      {:error, changeset} -> conn |> put_status(400) |> render("manage.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => key_access_id}) do
    key_access = Keys.find_key_access(key_access_id)

    if key_access do
      Keys.delete_key_access!(key_access)
      conn |> put_status(200) |> render("delete.json", key_access: key_access)
    else
      conn |> put_status(404) |> render("delete.json", key_access: nil)
    end
  end
end
