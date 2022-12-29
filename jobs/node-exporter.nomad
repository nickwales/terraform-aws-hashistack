job "node-exporter" {
  datacenters = ["dc1"]
  type = "system"

  group "node-exporter" {

    network {
      port "http" {
        static = 9100
        to = 9100
      }
    }

    restart {
      attempts = 3
      delay    = "20s"
      mode     = "delay"
    }

    task "node-exporter" {
      driver = "docker"

      config {
        image = "prom/node-exporter:latest"
        force_pull = true
        volumes = [
          "/proc:/host/proc",
          "/sys:/host/sys",
          "/:/rootfs"
        ]
        ports = ["http"]

        logging {
          type = "journald"
          config {
            tag = "NODE-EXPORTER"
          }
        }

      }

      service {
        name = "node-exporter"
        address_mode = "driver"
        tags = [
          "metrics"
        ]
        port = "http"


        check {
          type = "http"
          path = "/metrics/"
          interval = "10s"
          timeout = "2s"
        }
      }

      resources {
        cpu    = 55
        memory = 100
      }
    }
  }
}
