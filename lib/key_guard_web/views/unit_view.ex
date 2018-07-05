defmodule KeyGuardWeb.UnitView do
  use KeyGuardWeb, :view

  def render("manage.json", %{unit: nil}), do: unit_not_exists()

  def render("manage.json", %{unit: unit}) do
    %{"data" => %{"unit" => %{"id" => unit.id, "name" => unit.name, "parent_id" => unit.parent_id}}}
  end

  def render("manage.json", %{changeset: changeset}), do: format_validation_errors(changeset)

  def render("delete.json", %{unit: nil}), do: unit_not_exists()

  def render("delete.json", %{unit: unit}),
    do: %{"data" => %{"id" => unit.id, "message" => "Unit was successfully deleted"}}

  def render("unit.json", %{unit: nil}), do: unit_not_exists()

  def render("unit.json", %{unit: unit}) do
    data =
      %{}
      |> normalize_unit(unit.unit)
      |> normalize_children(unit.children)
      |> normalize_keys(unit.keys)

    %{"data" => data}
  end

  defp normalize_unit(unit, "root"), do: Map.put(unit, "unit", "root")

  defp normalize_unit(unit, unit_struct),
    do:
      Map.put(unit, "unit", %{
        "type" => "unit",
        "id" => unit_struct.id,
        "name" => unit_struct.name,
        "parent_id" => unit_struct.parent_id
      })

  defp normalize_children(unit, children) do
    normalized_children =
      Enum.map(children, &%{"type" => "unit", "id" => &1.id, "name" => &1.name, "parent_id" => &1.parent_id})

    Map.put(unit, "children", normalized_children)
  end

  defp normalize_keys(unit, keys) do
    normalized_keys =
      Enum.map(keys, &%{"type" => "key", "id" => &1.id, "name" => &1.name, "color" => &1.color, "extra" => &1.extra})

    Map.put(unit, "keys", normalized_keys)
  end

  defp unit_not_exists(), do: %{"error" => %{"message" => "Unit with given ID is not exists"}}
end
