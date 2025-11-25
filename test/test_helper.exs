System.put_env("BACKEND_URL", "http://localhost:4000")

ExUnit.start()

Mox.defmock(FrameCore.FileSystemMock, for: FrameCore.FileSystem)
Mox.defmock(FrameCore.HttpClientMock, for: FrameCore.HttpClient)
