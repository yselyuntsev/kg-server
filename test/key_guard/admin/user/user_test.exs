defmodule KeyGuard.Admin.UserTest do
  use KeyGuard.DataCase
  alias KeyGuard.Admin.User

  describe "roles/0" do
    test "returns a map of users roles" do
      assert User.roles() |> is_map()
    end
  end

  describe "role/1" do
    test "returns role ID by role name" do
      assert User.role(:moderator) == 0
      assert User.role(:admin) == 1
      assert User.role(:superadmin) == 2
    end
  end
end
