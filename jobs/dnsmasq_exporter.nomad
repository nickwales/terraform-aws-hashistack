job "dnsmasq-exporter" {
  datacenters = ["dc1"]
  type = "system"

  group "dnsmasq-exporter" {

    network {
      port "http" {
        static = 9153
        to = 9153
      }
    }

    restart {
      attempts = 3
      delay    = "20s"
      mode     = "delay"
    }

    task "dnsmasq-exporter" {
      driver = "docker"

      config {
        image = "ricardbejarano/dnsmasq_exporter"
        ports = ["http"]
      }

      env {
        DNSMASQ_SERVERS = "${attr.unique.network.ip-address}:5353"
      #  EXPORTER_LISTEN_ADDR = "0.0.0.0:9153"
      }

      service {
        name = "dnsmasq-exporter"
        tags = [
          "metrics"
        ]
        port = "http"


        // check {
        //   type = "http"
        //   path = "/metrics/"
        //   interval = "10s"
        //   timeout = "2s"
        // }
      }

      resources {
        cpu    = 55
        memory = 100
      }
    }
  }
}
