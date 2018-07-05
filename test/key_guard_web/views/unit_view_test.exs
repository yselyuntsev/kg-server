defmodule KeyGuardWeb.UnitViewTest do
  use KeyGuardWeb.ConnCase
  alias KeyGuardWeb.{UnitView, ErrorHelpers}
  alias KeyGuard.{TestUtils, Units, Keys}
  alias KeyGuard.Units.Unit
  alias KeyGuard.Units.Unit.Validator, as: UnitValidator
  import KeyGuard.Factory

  describe "render manage.json" do
    setup do
      unit = insert(:unit)
      changeset = UnitValidator.changeset(%Unit{}, %{"name" => TestUtils.generate_string(256)})

      {:ok, unit: unit, changeset: changeset}
    end

    test "successful response", %{unit: unit} do
      expected = %{
        "data" => %{"unit" => %{"id" => unit.id, "name" => unit.name, "parent_id" => unit.parent_id}}
      }

      assert UnitView.render("manage.json", unit: unit) == expected
    end

    test "unit ID error response" do
      assert UnitView.render("manage.json", unit: nil) == %{
               "error" => %{"message" => "Unit with given ID is not exists"}
             }
    end

    test "validation error response", %{changeset: changeset} do
      assert UnitView.render("manage.json", changeset: changeset) == ErrorHelpers.format_validation_errors(changeset)
    end
  end

  describe "render delete.json" do
    setup do
      unit = insert(:unit)
      {:ok, unit: unit}
    end

    test "successful response", %{unit: unit} do
      assert UnitView.render("delete.json", %{unit: unit}) == %{
               "data" => %{"id" => unit.id, "message" => "Unit was successfully deleted"}
             }
    end

    test "key ID error response" do
      assert UnitView.render("delete.json", %{unit: nil}) == %{
               "error" => %{"message" => "Unit with given ID is not exists"}
             }
    end
  end

  describe "render unit.json" do
    setup do
      unit1 = insert(:unit)
      unit2 = insert(:unit, parent_id: unit1.id)
      key = insert(:key)

      Keys.add_to_unit(key, unit1)

      {:ok, unit1: unit1, unit2: unit2, key: key}
    end

    test "successful root response", ctx do
      unit = Units.show_unit()

      assert UnitView.render("unit.json", unit: unit) == %{
               "data" => %{
                 "unit" => "root",
                 "children" => [
                   %{
                     "type" => "unit",
                     "id" => ctx.unit1.id,
                     "name" => ctx.unit1.name,
                     "parent_id" => ctx.unit1.parent_id
                   }
                 ],
                 "keys" => []
               }
             }
    end

    test "successful unit response", ctx do
      unit = Units.show_unit(ctx.unit1)

      assert UnitView.render("unit.json", unit: unit) == %{
               "data" => %{
                 "unit" => %{
                   "type" => "unit",
                   "id" => ctx.unit1.id,
                   "name" => ctx.unit1.name,
                   "parent_id" => ctx.unit1.parent_id
                 },
                 "children" => [
                   %{
                     "type" => "unit",
                     "id" => ctx.unit2.id,
                     "name" => ctx.unit2.name,
                     "parent_id" => ctx.unit2.parent_id
                   }
                 ],
                 "keys" => [
                   %{
                     "type" => "key",
                     "id" => ctx.key.id,
                     "name" => ctx.key.name,
                     "color" => ctx.key.color,
                     "extra" => ctx.key.extra
                   }
                 ]
               }
             }
    end

    test "key ID error response" do
      assert UnitView.render("unit.json", unit: nil) == %{"error" => %{"message" => "Unit with given ID is not exists"}}
    end
  end
end
