defmodule KeyGuardWeb.KeyView do
  use KeyGuardWeb, :view

  def render("index.json", %{keys: keys}), do: %{"data" => %{"keys" => Enum.map(keys, &normalize_key/1)}}

  def render("show.json", %{key: nil}),
    do: %{"error" => %{"message" => "Ключ не найден"}}

  def render("show.json", %{key: key}), do: key_info(key)

  def render("manage.json", %{key: nil}), do: key_not_exists()

  def render("manage.json", %{key: key}) do
    %{"data" => %{"key" => normalize_key(key)}}
  end

  def render("manage.json", %{changeset: changeset}), do: format_validation_errors(changeset)

  def render("delete.json", %{key: nil}), do: key_not_exists()

  def render("delete.json", %{key: key}),
    do: %{"data" => %{"id" => key.id, "message" => "Key was successfully deleted"}}

  def render("add_to_unit.json", %{key: nil}), do: key_not_exists()

  def render("add_to_unit.json", %{unit: nil}), do: unit_not_exists()

  def render("add_to_unit.json", %{key: key, unit: unit}), do: %{"data" => %{"key_id" => key.id, "unit_id" => unit.id}}

  def render("add_to_unit.json", %{error: :already_exists}), do: %{"error" => %{"message" => "Key is already in unit"}}

  def render("remove_from_unit.json", %{key: nil}), do: key_not_exists()

  def render("remove_from_unit.json", %{unit: nil}), do: unit_not_exists()

  def render("remove_from_unit.json", %{key: key, unit: unit}),
    do: %{"data" => %{"key_id" => key.id, "unit_id" => unit.id, "message" => "Key was successfully removed from unit"}}

  def render("remove_from_unit.json", %{error: :not_in_unit}), do: %{"error" => %{"message" => "Key isn't in unit"}}

  def render("take_or_return.json", %{key: nil}), do: key_not_exists()

  def render("take_or_return.json", %{employee: nil}), do: employee_not_exists()

  def render("take_or_return.json", %{error: :no_access}),
    do: %{"error" => %{"message" => "Employee has no access to take this key"}}

  def render("take_or_return.json", %{keys_journal: keys_journal}) do
    {employee_id, action} =
      if keys_journal.returned_at, do: {keys_journal.returned_by, "return"}, else: {keys_journal.taken_by, "take"}

    %{"data" => %{"key_id" => keys_journal.key_id, "employee_id" => employee_id, "action" => action}}
  end

  def render("taken_keys.json", %{keys: keys}), do: %{"data" => %{"keys" => Enum.map(keys, &taken_key/1)}}

  defp key_not_exists(), do: %{"error" => %{"message" => "Key with given ID is not exists"}}

  defp unit_not_exists(), do: %{"error" => %{"message" => "Unit with given ID is not exists"}}

  defp employee_not_exists(), do: %{"error" => %{"message" => "Employee with given ID is not exists"}}

  defp normalize_key(key), do: %{"id" => key.id, "name" => key.name, "color" => key.color, "extra" => key.extra}

  defp taken_key(key), do: %{"key_id" => key.key_id, "taken_by" => key.taken_by, "returned_by" => key.returned_by, "taken_at" => key.taken_at}

  defp key_info(key) do %{"data" => %{"key" => %{"id" => key.id, "name" => key.name, "color" => key.color, "extra" => key.extra}}}
  end
end
