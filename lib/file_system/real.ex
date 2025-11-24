defmodule FrameCore.FileSystem.Real do
  @moduledoc """
  Real file system implementation.
  """

  @behaviour FrameCore.FileSystem

  @impl true
  def read(path), do: File.read(path)

  @impl true
  def write!(path, content), do: File.write!(path, content)
end
