defmodule FrameCore.HttpClient do
  @moduledoc """
  Behavior for HTTP client operations.
  """

  @type url :: String.t()
  @type params :: map()
  @type headers :: [{String.t(), String.t()}]
  @type json_response :: term()
  @type error :: {:error, term()}

  @callback get_json(url(), params(), headers()) :: {:ok, json_response()} | error()
end
