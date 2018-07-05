defmodule KeyGuardWeb.ErrorHelpersTest do
  use KeyGuardWeb.ConnCase
  alias KeyGuardWeb.ErrorHelpers
  alias KeyGuard.TestUtils
  alias KeyGuard.Keys.Key
  alias KeyGuard.Keys.Key.Validator, as: KeyValidator

  describe "format_validation_errors/1" do
    setup do
      changeset = KeyValidator.create_changeset(%Key{}, %{"name" => TestUtils.generate_string(256)})
      {:ok, changeset: changeset}
    end

    test "formats validation errors", %{changeset: changeset} do
      expected = %{
        "error" => %{
          "id" => "can't be blank",
          "name" => "should be at most 50 character(s)",
          "color" => "can't be blank"
        }
      }

      assert ErrorHelpers.format_validation_errors(changeset) == expected
    end
  end
end
