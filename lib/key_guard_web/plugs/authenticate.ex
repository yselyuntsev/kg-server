defmodule KeyGuardWeb.Plug.Authenticate do
  @moduledoc "Plug for API authorization."

  alias KeyGuard.Repo
  alias KeyGuard.Admin.User
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts \\ []) do
    token = fetch_token(conn)

    case authorize(token) do
      {:ok, user} ->
        assign(conn, :current_user, user)

      {:error, :not_authorized} ->
        conn
        |> put_unathorized_header(token)
        |> put_status(401)
        |> Phoenix.Controller.json(%{"error" => %{"message" => "Authentication error"}})
        |> halt()
    end
  end

  defp fetch_token(conn) do
    case get_req_header(conn, "authorization") do
      [token] -> token
      _ -> nil
    end
  end

  defp authorize(token) when token in [nil, ""], do: {:error, :not_authorized}

  defp authorize(token) do
    user = Repo.get_by(User, token: token)
    if user, do: {:ok, user}, else: {:error, :not_authorized}
  end

  defp put_unathorized_header(conn, nil), do: conn
  defp put_unathorized_header(conn, token), do: put_resp_header(conn, "www-authenticate", token)
end
