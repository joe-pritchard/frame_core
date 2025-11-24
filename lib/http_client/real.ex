defmodule FrameCore.HttpClient.Real do
  @moduledoc """
  Real HTTP client implementation using Req.
  """

  @behaviour FrameCore.HttpClient

  @impl true
  @spec get_json(String.t(), map(), list()) :: {:ok, term()} | {:error, term()}
  def get_json(url, params, headers) do
    # Add Content-Type header for JSON
    json_headers = [{"content-type", "application/json"} | headers]

    case Req.get(url, params: params, headers: json_headers) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %Req.Response{status: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  @spec get_file(String.t(), list()) :: {:ok, binary()} | {:error, term()}
  def get_file(url, headers) do
    case Req.get(url, headers: headers) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %Req.Response{status: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
