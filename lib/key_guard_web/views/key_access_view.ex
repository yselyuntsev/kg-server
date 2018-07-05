defmodule KeyGuardWeb.KeyAccessView do
  use KeyGuardWeb, :view

  def render("index.json", %{keys_access: keys_access}), do: %{"data" => %{"key_access" => Enum.map(keys_access, &normalize_key_access/1)}}

  def render("show.json", %{keys_access: keys_access}), do: %{"data" => %{"key_access" => Enum.map(keys_access, &normalize_key_access/1)}}

  def render("manage.json", %{key_access: nil}), do: key_access_not_exists()

  def render("manage.json", %{key: nil}), do: %{"error" => %{"message" => "Key with given ID is not exists"}}

  def render("manage.json", %{employee: nil}), do: %{"error" => %{"message" => "Employee with given ID is not exists"}}

  def render("manage.json", %{key_access: key_access}) do
    %{
      "data" => %{
        "key_access" => %{
          "id" => key_access.id,
          "key_id" => key_access.key_id,
          "employee_id" => key_access.employee_id,
          "access_type" => "#{key_access.access_type}"
        }
      }
    }
  end

  def render("manage.json", %{changeset: changeset}), do: format_validation_errors(changeset)

  def render("delete.json", %{key_access: nil}), do: key_access_not_exists()

  def render("delete.json", %{key_access: key_access}),
    do: %{"data" => %{"id" => key_access.id, "message" => "Key access was successfully deleted"}}

  defp key_access_not_exists(), do: %{"error" => %{"message" => "Key access with given ID is not exists"}}

  defp normalize_key_access(key_access), do: %{
    "id" => key_access.id,
    "key_id" => key_access.key_id,
    "employee_id" => key_access.employee_id,
    "access_type" => "#{key_access.access_type}"
  }
end
