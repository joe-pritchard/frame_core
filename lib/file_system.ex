defmodule FrameCore.FileSystem do
  @moduledoc """
  Behavior for file system operations.
  """

  @callback read(Path.t()) :: {:ok, binary()} | {:error, File.posix()}
  @callback write!(Path.t(), iodata()) :: :ok
end
