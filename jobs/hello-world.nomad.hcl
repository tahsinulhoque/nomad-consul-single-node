job "docker-hello-world" {
  datacenters = ["dc1"]
  type        = "batch"

  group "hello-world" {
    task "hello-world" {
      driver = "docker"

      config {
        image      = "hello-world:latest"
        force_pull = false
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}
