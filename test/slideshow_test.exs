defmodule FrameCore.SlideshowTest do
  use ExUnit.Case, async: false
  import Mox

  setup :verify_on_exit!
  setup :set_mox_global

  alias FrameCore.Slideshow
  alias FrameCore.Backend

  describe "Slideshow" do
    test "initializes with no last_fetch when file doesn't exist" do
      expect(FrameCore.FileSystemMock, :read, fn "last_fetch.txt" ->
        {:error, :enoent}
      end)

      expect(FrameCore.FileSystemMock, :list_dir, fn "images" ->
        {:error, :enoent}
      end)

      config = %Slideshow.Config{
        file_system: FrameCore.FileSystemMock
      }

      {:ok, _pid} = start_supervised({Slideshow, config})

      assert Slideshow.list_images() == []
    end

    test "loads last_fetch from file if it exists" do
      last_fetch = ~U[2025-11-24 12:00:00Z]
      iso_string = DateTime.to_iso8601(last_fetch)

      expect(FrameCore.FileSystemMock, :read, fn "last_fetch.txt" ->
        {:ok, iso_string}
      end)

      expect(FrameCore.FileSystemMock, :list_dir, fn "images" ->
        {:error, :enoent}
      end)

      config = %Slideshow.Config{
        file_system: FrameCore.FileSystemMock
      }

      {:ok, _pid} = start_supervised({Slideshow, config})

      assert Slideshow.list_images() == []
    end

    test "initializes with existing images from filesystem" do
      expect(FrameCore.FileSystemMock, :read, fn "last_fetch.txt" ->
        {:error, :enoent}
      end)

      expect(FrameCore.FileSystemMock, :list_dir, fn "images" ->
        {:ok, ["images/1.jpg", "images/2.png", "images/3.gif"]}
      end)

      config = %Slideshow.Config{
        file_system: FrameCore.FileSystemMock
      }

      {:ok, _pid} = start_supervised({Slideshow, config})

      images = Slideshow.list_images()
      assert length(images) == 3
      assert "images/1.jpg" in images
      assert "images/2.png" in images
      assert "images/3.gif" in images
    end

    test "returns error when no images available" do
      expect(FrameCore.FileSystemMock, :read, fn "last_fetch.txt" ->
        {:error, :enoent}
      end)

      expect(FrameCore.FileSystemMock, :list_dir, fn "images" ->
        {:error, :enoent}
      end)

      config = %Slideshow.Config{
        file_system: FrameCore.FileSystemMock
      }

      {:ok, _pid} = start_supervised({Slideshow, config})

      assert {:error, :no_images} = Slideshow.get_random_image()
    end

    test "refresh fetches images from backend and saves last_fetch" do
      expect(FrameCore.FileSystemMock, :read, fn "last_fetch.txt" ->
        {:error, :enoent}
      end)

      expect(FrameCore.FileSystemMock, :list_dir, fn "images" ->
        {:error, :enoent}
      end)

      expect(FrameCore.FileSystemMock, :write!, fn "last_fetch.txt", content ->
        assert {:ok, _dt, _offset} = DateTime.from_iso8601(content)
        :ok
      end)

      expect(FrameCore.HttpClientMock, :get_json, fn _url, _params, _headers ->
        {:ok, %{"images" => []}}
      end)

      backend_config = %Backend.Config{
        device_id: "test-device-123",
        client: FrameCore.HttpClientMock,
        backend_url: "https://api.example.com"
      }

      start_supervised({Backend, backend_config})

      slideshow_config = %Slideshow.Config{
        file_system: FrameCore.FileSystemMock
      }

      {:ok, _pid} = start_supervised({Slideshow, slideshow_config})

      assert :ok = Slideshow.refresh()
    end

    test "refresh passes last_fetch to backend" do
      last_fetch = ~U[2025-11-24 10:00:00Z]
      iso_string = DateTime.to_iso8601(last_fetch)

      expect(FrameCore.FileSystemMock, :read, fn "last_fetch.txt" ->
        {:ok, iso_string}
      end)

      expect(FrameCore.FileSystemMock, :list_dir, fn "images" ->
        {:error, :enoent}
      end)

      expect(FrameCore.FileSystemMock, :write!, fn "last_fetch.txt", _content ->
        :ok
      end)

      expect(FrameCore.HttpClientMock, :get_json, fn _url, params, _headers ->
        assert params["since"] == iso_string
        {:ok, %{"images" => []}}
      end)

      backend_config = %Backend.Config{
        device_id: "test-device-123",
        client: FrameCore.HttpClientMock,
        backend_url: "https://api.example.com"
      }

      start_supervised({Backend, backend_config})

      slideshow_config = %Slideshow.Config{
        file_system: FrameCore.FileSystemMock
      }

      {:ok, _pid} = start_supervised({Slideshow, slideshow_config})

      assert :ok = Slideshow.refresh()
    end

    test "handles backend errors gracefully" do
      expect(FrameCore.FileSystemMock, :read, fn "last_fetch.txt" ->
        {:error, :enoent}
      end)

      expect(FrameCore.FileSystemMock, :list_dir, fn "images" ->
        {:error, :enoent}
      end)

      expect(FrameCore.HttpClientMock, :get_json, fn _url, _params, _headers ->
        {:error, :timeout}
      end)

      backend_config = %Backend.Config{
        device_id: "test-device-123",
        client: FrameCore.HttpClientMock,
        backend_url: "https://api.example.com"
      }

      start_supervised({Backend, backend_config})

      slideshow_config = %Slideshow.Config{
        file_system: FrameCore.FileSystemMock
      }

      {:ok, _pid} = start_supervised({Slideshow, slideshow_config})

      assert {:error, :timeout} = Slideshow.refresh()
    end

    test "get_random_image returns an image from available images" do
      expect(FrameCore.FileSystemMock, :read, fn "last_fetch.txt" ->
        {:error, :enoent}
      end)

      expect(FrameCore.FileSystemMock, :list_dir, fn "images" ->
        {:ok, ["images/1.jpg", "images/2.jpg"]}
      end)

      config = %Slideshow.Config{
        file_system: FrameCore.FileSystemMock
      }

      {:ok, _pid} = start_supervised({Slideshow, config})

      assert {:ok, image} = Slideshow.get_random_image()
      assert is_binary(image)
      assert image in ["images/1.jpg", "images/2.jpg"]
    end

    test "list_images returns all available images" do
      expect(FrameCore.FileSystemMock, :read, fn "last_fetch.txt" ->
        {:error, :enoent}
      end)

      expect(FrameCore.FileSystemMock, :list_dir, fn "images" ->
        {:ok, ["images/1.jpg", "images/2.png"]}
      end)

      config = %Slideshow.Config{
        file_system: FrameCore.FileSystemMock
      }

      {:ok, _pid} = start_supervised({Slideshow, config})

      images = Slideshow.list_images()
      assert length(images) == 2
      assert "images/1.jpg" in images
      assert "images/2.png" in images
    end
  end
end
