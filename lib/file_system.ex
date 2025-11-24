defmodule FrameCore.FileSystem do
  @moduledoc """
  Behavior for file system operations.
  """

  @type path :: Path.t()
  @type posix_error :: File.posix()

  @callback read(path()) :: {:ok, binary()} | {:error, posix_error()}
  @callback write!(path(), iodata()) :: :ok
end
