defmodule FrameCore do
  @moduledoc """
  Top-level supervisor that orchestrates DeviceId, Backend, and Slideshow processes.
  """

  use Application

  alias FrameCore.{Backend, DeviceId, FileSystem, HttpClient, Slideshow}

  @impl true
  def start(_type, _args) do
    children = [
      {DeviceId, %DeviceId.Config{file_system: FileSystem.Real}},
      {Backend, %Backend.Config{client: HttpClient.Real}},
      {Enrolment, []},
      {Slideshow, %Slideshow.Config{file_system: FileSystem.Real}}
    ]

    Supervisor.start_link(children, strategy: :rest_for_one)
  end
end
