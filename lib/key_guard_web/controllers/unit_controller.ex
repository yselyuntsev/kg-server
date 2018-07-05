defmodule KeyGuardWeb.UnitController do
  use KeyGuardWeb, :controller
  alias KeyGuard.Units

  def index(conn, _params) do
    unit = Units.show_unit()
    conn |> put_status(200) |> render("unit.json", unit: unit)
  end

  def show(conn, %{"id" => unit_id}) do
    unit = Units.find_unit(unit_id)

    if unit do
      unit_with_content = Units.show_unit(unit)
      conn |> put_status(200) |> render("unit.json", unit: unit_with_content)
    else
      conn |> put_status(404) |> render("unit.json", unit: nil)
    end
  end

  def create(conn, params) do
    case Units.create_unit(params) do
      {:ok, created_unit} -> conn |> put_status(201) |> render("manage.json", unit: created_unit)
      {:error, changeset} -> conn |> put_status(400) |> render("manage.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => unit_id} = params) do
    with unit when not is_nil(unit) <- Units.find_unit(unit_id),
         {:ok, updated_unit} <- Units.update_unit(unit, params) do
      conn |> put_status(200) |> render("manage.json", unit: updated_unit)
    else
      nil -> conn |> put_status(404) |> render("manage.json", unit: nil)
      {:error, changeset} -> conn |> put_status(400) |> render("manage.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => unit_id}) do
    unit = Units.find_unit(unit_id)

    if unit do
      Units.delete_unit!(unit)
      conn |> put_status(200) |> render("delete.json", unit: unit)
    else
      conn |> put_status(404) |> render("delete.json", unit: nil)
    end
  end
end
