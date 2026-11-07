job "hello-world-service" {
  datacenters = ["dc1"]
  type        = "service"

  group "hello-world" {
    count = 1

    network {
      port "http" {
        to = 5678
      }
    }

    service {
      name     = "hello-world"
      provider = "consul"
      port     = "http"

      check {
        name     = "hello-world-tcp-check"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "hello-world" {
      driver = "docker"

      config {
        image   = "hashicorp/http-echo:1.0.0"
        ports   = ["http"]
        command = "/http-echo"
        args    = ["-listen=:5678", "-text=Hello from Nomad and Consul!"]
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}
