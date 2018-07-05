defmodule KeyGuardWeb.KeyViewTest do
  use KeyGuardWeb.ConnCase
  alias KeyGuardWeb.{KeyView, ErrorHelpers}
  alias KeyGuard.TestUtils
  alias KeyGuard.Keys.Key
  alias KeyGuard.Keys.Key.Validator, as: KeyValidator
  import KeyGuard.Factory

  describe "render index.json" do
    setup do
      key = insert(:key)
      {:ok, key: key}
    end

    test "successful response", %{key: key} do
      assert KeyView.render("index.json", keys: [key]) == %{
               "data" => %{
                 "keys" => [%{"id" => key.id, "name" => key.name, "color" => key.color, "extra" => key.extra}]
               }
             }
    end
  end

  describe "render show.json" do
    setup do
      key = insert(:key)
      {:ok, key: key}
    end

    test "successful response", %{key: key} do
      expected = %{
        "data" => %{
          "key" => %{
            "id" => key.id,
            "name" => key.name,
            "color" => key.color,
            "extra" => key.extra
          }
        }
      }

      assert KeyView.render("show.json", key: key) == expected
    end

    test "key id error response" do
      assert KeyView.render("show.json", key: nil) == %{
               "error" => %{"message" => "Ключ не найден"}
             }
    end
  end

  describe "render manage.json" do
    setup do
      key = insert(:key)
      changeset = KeyValidator.create_changeset(%Key{}, %{"name" => TestUtils.generate_string(256)})

      {:ok, key: key, changeset: changeset}
    end

    test "successful response", %{key: key} do
      expected = %{
        "data" => %{"key" => %{"id" => key.id, "name" => key.name, "color" => key.color, "extra" => key.extra}}
      }

      assert KeyView.render("manage.json", key: key) == expected
    end

    test "key ID error response" do
      assert KeyView.render("manage.json", key: nil) == %{"error" => %{"message" => "Key with given ID is not exists"}}
    end

    test "validation error response", %{changeset: changeset} do
      assert KeyView.render("manage.json", changeset: changeset) == ErrorHelpers.format_validation_errors(changeset)
    end
  end

  describe "render delete.json" do
    setup do
      key = insert(:key)
      {:ok, key: key}
    end

    test "successful response", %{key: key} do
      assert KeyView.render("delete.json", %{key: key}) == %{
               "data" => %{"id" => key.id, "message" => "Key was successfully deleted"}
             }
    end

    test "key ID error response" do
      assert KeyView.render("delete.json", %{key: nil}) == %{
               "error" => %{"message" => "Key with given ID is not exists"}
             }
    end
  end

  describe "render add_to_unit.json" do
    setup do
      key = insert(:key)
      unit = insert(:unit)

      {:ok, key: key, unit: unit}
    end

    test "successful response", %{key: key, unit: unit} do
      assert KeyView.render("add_to_unit.json", %{key: key, unit: unit}) == %{
               "data" => %{"key_id" => key.id, "unit_id" => unit.id}
             }
    end

    test "conflict response" do
      assert KeyView.render("add_to_unit.json", %{error: :already_exists}) == %{
               "error" => %{"message" => "Key is already in unit"}
             }
    end

    test "key ID error response", %{unit: unit} do
      assert KeyView.render("add_to_unit.json", %{key: nil, unit: unit}) == %{
               "error" => %{"message" => "Key with given ID is not exists"}
             }
    end

    test "unit ID error response", %{key: key} do
      assert KeyView.render("add_to_unit.json", %{key: key, unit: nil}) == %{
               "error" => %{"message" => "Unit with given ID is not exists"}
             }
    end
  end

  describe "render remove_from_unit.json" do
    setup do
      key = insert(:key)
      unit = insert(:unit)

      {:ok, key: key, unit: unit}
    end

    test "successful response", %{key: key, unit: unit} do
      assert KeyView.render("remove_from_unit.json", %{key: key, unit: unit}) == %{
               "data" => %{
                 "key_id" => key.id,
                 "unit_id" => unit.id,
                 "message" => "Key was successfully removed from unit"
               }
             }
    end

    test "error response" do
      assert KeyView.render("remove_from_unit.json", %{error: :not_in_unit}) == %{
               "error" => %{"message" => "Key isn't in unit"}
             }
    end

    test "key ID error response", %{unit: unit} do
      assert KeyView.render("remove_from_unit.json", %{key: nil, unit: unit}) == %{
               "error" => %{"message" => "Key with given ID is not exists"}
             }
    end

    test "unit ID error response", %{key: key} do
      assert KeyView.render("remove_from_unit.json", %{key: key, unit: nil}) == %{
               "error" => %{"message" => "Unit with given ID is not exists"}
             }
    end
  end

  describe "render take_or_return.json" do
    test "successful take response" do
      keys_journal = insert(:keys_journal, returned_at: nil, returned_by: nil)

      assert KeyView.render("take_or_return.json", %{keys_journal: keys_journal}) == %{
               "data" => %{"key_id" => keys_journal.key_id, "employee_id" => keys_journal.taken_by, "action" => "take"}
             }
    end

    test "successful return response" do
      keys_journal = insert(:keys_journal)

      assert KeyView.render("take_or_return.json", %{keys_journal: keys_journal}) == %{
               "data" => %{
                 "key_id" => keys_journal.key_id,
                 "employee_id" => keys_journal.returned_by,
                 "action" => "return"
               }
             }
    end

    test "key ID error response" do
      assert KeyView.render("take_or_return.json", %{key: nil}) == %{
               "error" => %{"message" => "Key with given ID is not exists"}
             }
    end

    test "employee ID error response" do
      assert KeyView.render("take_or_return.json", %{employee: nil}) == %{
               "error" => %{"message" => "Employee with given ID is not exists"}
             }
    end

    test "access error response" do
      assert KeyView.render("take_or_return.json", %{error: :no_access}) == %{
               "error" => %{"message" => "Employee has no access to take this key"}
             }
    end
  end
end
