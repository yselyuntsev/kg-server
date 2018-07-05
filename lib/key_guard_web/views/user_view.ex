defmodule KeyGuardWeb.UserView do
  use KeyGuardWeb, :view

  def render("manage.json", %{user: user}),
    do: %{"data" => %{"user" => %{"id" => user.id, "username" => user.username, "role" => user.role}}}

  def render("manage.json", %{changeset: changeset}), do: format_validation_errors(changeset)

  def render("manage.json", %{error: :role_not_allowed}), do: %{"error" => %{"message" => "Role not allowed"}}

  def render("authenticate.json", %{token: token}), do: %{"data" => %{"token" => token}}

  def render("authenticate.json", %{error: :wrong_params}),
    do: %{"error" => %{"message" => "Invalid username or password"}}
end
