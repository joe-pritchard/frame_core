defmodule FrameCore.FileSystem.Real do
  @moduledoc """
  Real file system implementation.
  """

  @behaviour FrameCore.FileSystem

  @impl true
  def read(path), do: File.read(path)

  @impl true
  def write!(path, content), do: File.write!(path, content)

  @impl true
  def list_dir(path) do
    case File.ls(path) do
      {:ok, files} ->
        # Return full paths, not just filenames
        full_paths = Enum.map(files, fn file -> Path.join(path, file) end)
        {:ok, full_paths}

      {:error, _} = error ->
        error
    end
  end

  @impl true
  def rm(path), do: File.rm(path)

  @impl true
  def mkdir_p(path), do: File.mkdir_p(path)
end
