defmodule KeyGuardWeb.UserControllerTest do
  use KeyGuardWeb.ConnCase
  alias KeyGuard.Admin.User
  alias KeyGuard.{Admin, Repo}
  import KeyGuard.Factory

  setup do
    conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
    user = insert(:user, role: Admin.role(:admin))

    {:ok, conn: conn, user: user}
  end

  describe "POST /api/v1/admin/users" do
    setup ctx do
      conn = ctx.user |> auth_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      [conn: conn]
    end

    test "returns successful response", ctx do
      params = %{"username" => "admin", "password" => "password", "role" => Admin.role(:moderator)}
      conn = post(ctx.conn, user_path(ctx.conn, :create), Poison.encode!(params))
      user = Repo.get_by!(User, username: params["username"])

      assert json_response(conn, 202) == %{
               "data" => %{"user" => %{"id" => user.id, "username" => user.username, "role" => user.role}}
             }
    end

    test "returns validation error response", ctx do
      params =
        %{"username" => "in va lid", "password" => "password", "role" => Admin.role(:moderator)} |> Poison.encode!()

      conn = post(ctx.conn, user_path(ctx.conn, :create), params)

      assert json_response(conn, 400) == %{"error" => %{"username" => "has invalid format"}}
    end

    test "returns role not allower error", ctx do
      params = %{"username" => "admin", "password" => "password", "role" => Admin.role(:admin)} |> Poison.encode!()
      conn = post(ctx.conn, user_path(ctx.conn, :create), params)

      assert json_response(conn, 400) == %{"error" => %{"message" => "Role not allowed"}}
    end

    test "when user is not authenticated" do
      conn = build_conn()
      conn = post(conn, user_path(conn, :create), %{})

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "GET /api/v1/admin/users/authenticate" do
    test "returns a token after successful authentication", ctx do
      params = %{"username" => ctx.user.username, "password" => "password"} |> Poison.encode!()
      conn = post(ctx.conn, user_path(ctx.conn, :authenticate), params)

      assert json_response(conn, 200) == %{"data" => %{"token" => ctx.user.token}}
    end

    test "returns an error when params are invalid", ctx do
      params = %{"username" => ctx.user.username, "password" => "wrong-password"} |> Poison.encode!()
      conn = post(ctx.conn, user_path(ctx.conn, :authenticate), params)

      assert json_response(conn, 401) == %{"error" => %{"message" => "Invalid username or password"}}
    end

    test "returns an error when user is alredy authenticated", ctx do
      params = %{"username" => ctx.user.username, "password" => "password"} |> Poison.encode!()
      conn = ctx.user |> auth_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = post(conn, user_path(conn, :authenticate), params)

      assert json_response(conn, 403) == %{"error" => %{"message" => "Unauthenticated only"}}
    end
  end
end
