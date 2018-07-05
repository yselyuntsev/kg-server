defmodule KeyGuardWeb.UserController do
  use KeyGuardWeb, :controller
  alias KeyGuard.Admin

  def create(conn, params) do
    case Admin.create_user(params, conn.assigns[:current_user]) do
      {:ok, created_user} ->
        conn |> put_status(202) |> render("manage.json", user: created_user)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn |> put_status(400) |> render("manage.json", changeset: changeset)

      {:error, reason} ->
        conn |> put_status(400) |> render("manage.json", error: reason)
    end
  end

  def authenticate(conn, params) do
    case Admin.authenticate_user(params) do
      {:ok, token} -> conn |> put_status(200) |> render("authenticate.json", token: token)
      {:error, reason} -> conn |> put_status(401) |> render("authenticate.json", error: reason)
    end
  end

  def status(conn, _params) do
    send_resp(conn, 200, "")
  end
end
