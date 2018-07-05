defmodule KeyGuardWeb.KeyAccessViewTest do
  use KeyGuardWeb.ConnCase
  alias KeyGuardWeb.{KeyAccessView, ErrorHelpers}
  alias KeyGuard.Keys.KeyAccess
  alias KeyGuard.Keys.KeyAccess.Validator, as: KeyAccessValidator
  import KeyGuard.Factory

  setup do
    key_access = insert(:key_access)
    changeset = KeyAccessValidator.create_changeset(%KeyAccess{}, %{"access_type" => "fake"})

    {:ok, key_access: key_access, changeset: changeset}
  end

  describe "render index.json" do
    test "successful response", %{key_access: key_access} do
      assert KeyAccessView.render("index.json", keys_access: [key_access]) == %{
        "data" => %{
          "key_access" => [%{
            "id" => key_access.id,
            "key_id" => key_access.key_id,
            "employee_id" => key_access.employee_id,
            "access_type" => "#{key_access.access_type}"
          }]
        }
      }
    end
  end

  describe "render show.json" do
    test "successful response", %{key_access: key_access} do
      assert KeyAccessView.render("show.json", keys_access: [key_access]) == %{
        "data" => %{
          "key_access" => [%{
            "id" => key_access.id,
            "key_id" => key_access.key_id,
            "employee_id" => key_access.employee_id,
            "access_type" => "#{key_access.access_type}"
          }]
        }
      }
    end
  end

  describe "render manage.json" do
    test "successful response", %{key_access: key_access} do
      expected = %{
        "data" => %{
          "key_access" => %{
            "id" => key_access.id,
            "key_id" => key_access.key_id,
            "employee_id" => key_access.employee_id,
            "access_type" => "#{key_access.access_type}"
          }
        }
      }

      assert KeyAccessView.render("manage.json", key_access: key_access) == expected
    end

    test "key access ID error response" do
      assert KeyAccessView.render("manage.json", key_access: nil) == %{
               "error" => %{"message" => "Key access with given ID is not exists"}
             }
    end

    test "key ID error response" do
      assert KeyAccessView.render("manage.json", key: nil) == %{
               "error" => %{"message" => "Key with given ID is not exists"}
             }
    end

    test "employee ID error response" do
      assert KeyAccessView.render("manage.json", employee: nil) == %{
               "error" => %{"message" => "Employee with given ID is not exists"}
             }
    end

    test "validation error response", %{changeset: changeset} do
      assert KeyAccessView.render("manage.json", changeset: changeset) ==
               ErrorHelpers.format_validation_errors(changeset)
    end
  end

  describe "render delete.json" do
    test "successful response", %{key_access: key_access} do
      assert KeyAccessView.render("delete.json", %{key_access: key_access}) == %{
               "data" => %{"id" => key_access.id, "message" => "Key access was successfully deleted"}
             }
    end

    test "key access ID error response" do
      assert KeyAccessView.render("delete.json", %{key_access: nil}) == %{
               "error" => %{"message" => "Key access with given ID is not exists"}
             }
    end
  end
end
