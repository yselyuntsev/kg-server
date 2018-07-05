defmodule KeyGuardWeb.KeyController do
  use KeyGuardWeb, :controller
  alias KeyGuard.Keys.Key
  alias KeyGuard.Units.Unit
  alias KeyGuard.Staff.Employee
  alias KeyGuard.{Keys, Units, Staff}

  def index(conn, _params) do
    keys = Keys.all_keys()
    conn |> put_status(200) |> render("index.json", keys: keys)
  end

  def show(conn, params) do
    key = Keys.find_key(params["id"])
    conn |> put_status(200) |> render("show.json", key: key)
  end

  def create(conn, params) do
    case Keys.create_key(params) do
      {:ok, created_key} -> conn |> put_status(201) |> render("manage.json", key: created_key)
      {:error, changeset} -> conn |> put_status(400) |> render("manage.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => key_id} = params) do
    with key when not is_nil(key) <- Keys.find_key(key_id),
         {:ok, updated_key} <- Keys.update_key(key, params) do
      conn |> put_status(200) |> render("manage.json", key: updated_key)
    else
      nil -> conn |> put_status(404) |> render("manage.json", key: nil)
      {:error, changeset} -> conn |> put_status(400) |> render("manage.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => key_id}) do
    key = Keys.find_key(key_id)

    if key do
      Keys.delete_key!(key)
      conn |> put_status(200) |> render("delete.json", key: key)
    else
      conn |> put_status(404) |> render("delete.json", key: nil)
    end
  end

  def add_to_unit(conn, params) do
    key = Keys.find_key(params["key_id"])
    unit = Units.find_unit(params["unit_id"])

    with {:key, %Key{}} <- {:key, key},
         {:unit, %Unit{}} <- {:unit, unit},
         {:ok, _key, _unit} <- Keys.add_to_unit(key, unit) do
      conn |> put_status(200) |> render("add_to_unit.json", key: key, unit: unit)
    else
      {:key, nil} -> conn |> put_status(404) |> render("add_to_unit.json", key: nil)
      {:unit, nil} -> conn |> put_status(404) |> render("add_to_unit.json", unit: nil)
      {:error, reason} -> conn |> put_status(409) |> render("add_to_unit.json", error: reason)
    end
  end

  def remove_from_unit(conn, params) do
    key = Keys.find_key(params["key_id"])
    unit = Units.find_unit(params["unit_id"])

    with {:key, %Key{}} <- {:key, key},
         {:unit, %Unit{}} <- {:unit, unit},
         {:ok, _key, _unit} <- Keys.remove_from_unit(key, unit) do
      conn |> put_status(200) |> render("remove_from_unit.json", key: key, unit: unit)
    else
      {:key, nil} -> conn |> put_status(404) |> render("remove_from_unit.json", key: nil)
      {:unit, nil} -> conn |> put_status(404) |> render("remove_from_unit.json", unit: nil)
      {:error, reason} -> conn |> put_status(404) |> render("remove_from_unit.json", error: reason)
    end
  end

  def take_or_return(conn, params) do
    key = Keys.find_key(params["key_id"])
    employee = Staff.find_employee(params["employee_id"])

    with {:key, %Key{}} <- {:key, key},
         {:employee, %Employee{}} <- {:employee, employee},
         {:ok, keys_journal} <- Keys.take_or_return_key(key, employee) do
      conn |> put_status(200) |> render("take_or_return.json", keys_journal: keys_journal)
    else
      {:key, nil} -> conn |> put_status(404) |> render("take_or_return.json", key: nil)
      {:employee, nil} -> conn |> put_status(404) |> render("take_or_return.json", employee: nil)
      {:error, reason} -> conn |> put_status(400) |> render("take_or_return.json", error: reason)
    end
  end

  def employee_taken_keys(conn, params) do
    keys = Keys.taken_keys(params["employee_id"])
    conn |> put_status(200) |> render("taken_keys.json", keys: keys)
  end

  def all_taken_keys(conn, _params) do
    keys = Keys.all_taken_keys()
    conn |> put_status(200) |> render("taken_keys.json", keys: keys)
  end
end
