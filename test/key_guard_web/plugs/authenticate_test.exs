defmodule KeyGuard.Plug.AuthenticateTest do
  use KeyGuardWeb.ConnCase
  alias KeyGuardWeb.Plug.Authenticate
  alias KeyGuard.Admin.User
  import KeyGuard.Factory

  describe "call/2" do
    setup do
      user = insert(:user)
      conn = build_conn()

      {:ok, user: user, conn: conn}
    end

    test "with correct API key", ctx do
      payload = %{"status" => "ok"}

      conn =
        ctx.conn
        |> Plug.Conn.put_req_header("authorization", ctx.user.token)
        |> Authenticate.call()
        |> Phoenix.Controller.json(payload)

      user_id = ctx.user.id

      assert json_response(conn, 200) == payload
      assert %User{id: ^user_id} = conn.assigns[:current_user]
    end

    test "with incorrect API key", ctx do
      conn =
        ctx.conn
        |> Plug.Conn.put_req_header("authorization", "fake-token")
        |> Authenticate.call()

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
      assert ["fake-token"] = Plug.Conn.get_resp_header(conn, "www-authenticate")
      refute conn.assigns[:current_user]
    end

    test "without API key", ctx do
      conn = Authenticate.call(ctx.conn)
      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
      assert [] = Plug.Conn.get_resp_header(conn, "www-authenticate")
      refute conn.assigns[:current_user]
    end
  end
end
