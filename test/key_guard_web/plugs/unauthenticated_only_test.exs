defmodule KeyGuardWeb.Plug.UnauthenticatedOnlyTest do
  use KeyGuardWeb.ConnCase
  alias KeyGuardWeb.Plug.UnauthenticatedOnly
  import KeyGuard.Factory

  describe "call/2" do
    setup do
      user = insert(:user)
      {:ok, user: user}
    end

    test "when user is not authenticated" do
      payload = %{"status" => "ok"}
      conn = build_conn() |> UnauthenticatedOnly.call() |> Phoenix.Controller.json(payload)

      refute conn.halted
      assert json_response(conn, 200) == payload
    end

    test "when user is authenticated", %{user: user} do
      conn = user |> auth_conn() |> UnauthenticatedOnly.call()

      assert conn.halted
      assert json_response(conn, 403) == %{"error" => %{"message" => "Unauthenticated only"}}
    end
  end
end
