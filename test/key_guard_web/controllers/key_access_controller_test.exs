defmodule KeyGuardWeb.KeyAccessControllerTest do
  use KeyGuardWeb.ConnCase
  alias KeyGuard.Repo
  alias KeyGuard.Keys.KeyAccess
  import KeyGuard.Factory

  setup do
    key = insert(:key)
    employee = insert(:employee)
    key_access = insert(:key_access)
    conn = insert(:user) |> auth_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
    {:ok, key: key, employee: employee, key_access: key_access, conn: conn}
  end

  describe "GET /api/v1/key-access/:employee_id" do
    test "successful response", ctx do
      conn = get(ctx.conn, key_access_path(ctx.conn, :show, ctx.key_access.employee_id))
      assert json_response(conn, 200) == %{
               "data" => %{
                 "key_access" => [%{
                   "id" => ctx.key_access.id,
                   "key_id" => ctx.key_access.key_id,
                   "employee_id" => ctx.key_access.employee_id,
                   "access_type" => "#{ctx.key_access.access_type}"
                 }]
               }
             }
    end

    test "when user is not authenticated", ctx do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = get(conn, unit_path(conn, :show, ctx.employee.id))

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "GET /api/v1/key-access" do
    test "successful response", ctx do
      conn = get(ctx.conn, key_access_path(ctx.conn, :index))

      assert json_response(conn, 200) == %{
               "data" => %{
                 "key_access" => [%{
                   "id" => ctx.key_access.id,
                   "key_id" => ctx.key_access.key_id,
                   "employee_id" => ctx.key_access.employee_id,
                   "access_type" => "#{ctx.key_access.access_type}"
                   }]
                }
              }
    end

    test "when user is not authenticated" do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = get(conn, key_access_path(conn, :index))

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end    
  end

  describe "POST /api/v1/key-access" do
    test "returns new key access after successful creating", ctx do
      params = %{"key_id" => ctx.key.id, "employee_id" => ctx.employee.id, "access_type" => "true"}
      conn = post(ctx.conn, key_access_path(ctx.conn, :create), Poison.encode!(params))
      key_access_id = Repo.get_by(KeyAccess, key_id: ctx.key.id, employee_id: ctx.employee.id).id

      assert json_response(conn, 201) == %{
               "data" => %{
                 "key_access" => %{
                   "id" => key_access_id,
                   "key_id" => params["key_id"],
                   "employee_id" => params["employee_id"],
                   "access_type" => params["access_type"]
                 }
               }
             }
    end

    test "when some params are invalid", ctx do
      params = %{"key_id" => ctx.key.id, "employee_id" => ctx.employee.id, "access_type" => "fake"}
      conn = post(ctx.conn, key_access_path(ctx.conn, :create), params)

      assert json_response(conn, 400) == %{"error" => %{"access_type" => "is invalid"}}
    end

    test "when key with given ID isn't exists", ctx do
      params = %{"key_id" => "fake-id", "employee_id" => ctx.employee.id, "access_type" => "false"}
      conn = post(ctx.conn, key_access_path(ctx.conn, :create), params)

      assert json_response(conn, 404) == %{"error" => %{"message" => "Key with given ID is not exists"}}
    end

    test "when employee with given ID isn't exists", ctx do
      params = %{"key_id" => ctx.key.id, "employee_id" => 0, "access_type" => "false"}
      conn = post(ctx.conn, key_access_path(ctx.conn, :create), params)

      assert json_response(conn, 404) == %{"error" => %{"message" => "Employee with given ID is not exists"}}
    end

    test "when user is not authenticated" do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = post(conn, key_access_path(conn, :create), %{})

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "PUT /api/v1/key-access/:id" do
    test "returns updated key access after successful updating", ctx do
      params = %{"access_type" => "false"}
      conn = put(ctx.conn, key_access_path(ctx.conn, :update, ctx.key_access.id), Poison.encode!(params))

      assert json_response(conn, 200) == %{
               "data" => %{
                 "key_access" => %{
                   "id" => ctx.key_access.id,
                   "key_id" => ctx.key_access.key_id,
                   "employee_id" => ctx.key_access.employee_id,
                   "access_type" => params["access_type"]
                 }
               }
             }
    end

    test "when some params are invalid", ctx do
      params = %{"access_type" => "fake"} |> Poison.encode!()
      conn = put(ctx.conn, key_access_path(ctx.conn, :update, ctx.key_access.id), params)
      assert json_response(conn, 400) == %{"error" => %{"access_type" => "is invalid"}}
    end

    test "when key access with given ID isn't exists", %{conn: conn} do
      conn = put(conn, key_access_path(conn, :update, 0), %{})
      assert json_response(conn, 404) == %{"error" => %{"message" => "Key access with given ID is not exists"}}
    end

    test "when user is not authenticated", %{key_access: key_access} do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = put(conn, key_access_path(conn, :update, key_access.id), %{})

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "DELETE /api/v1/key-access/:id" do
    test "returns successful deletion message", %{conn: conn, key_access: key_access} do
      conn = delete(conn, key_access_path(conn, :delete, key_access.id))

      assert json_response(conn, 200) == %{
               "data" => %{"id" => key_access.id, "message" => "Key access was successfully deleted"}
             }
    end

    test "when key access with given ID isn't exists", %{conn: conn} do
      conn = delete(conn, key_access_path(conn, :delete, 0))
      assert json_response(conn, 404) == %{"error" => %{"message" => "Key access with given ID is not exists"}}
    end

    test "when user is not authenticated", %{key_access: key_access} do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = delete(conn, key_access_path(conn, :delete, key_access.id))

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end
end
