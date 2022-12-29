job "grafana" {
  region      = "global"
  datacenters = ["dc1"]

  constraint {
      attribute = "${node.class}"
      value = "monitoring"
  }

  group "grafana" {
    count = 1

    network {
      port "http" {
        static = 3000
        to = 3000
      }
    }

    service {
      name = "grafana"
      port = "3000"
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:9.3.2"
        ports = ["http"]
        volumes = [
          "local/datasource.yml:/etc/grafana/provisioning/datasources/prometheus.yml"
        ]
      }


      resources {
        cpu    = 200
        memory = 382
      }

      env {
        GF_PATHS_CONFIG = "/local/config.ini"
      }

      template {
        destination = "local/config.ini"
        data        = <<EOF
[database]
type = postgres
host = {{ env "attr.unique.network.ip-address" }}:5432
name = grafana
user = grafana
password = grafana
[server]
EOF
      }

      template {
          destination = "local/datasource.yml"
          data        = <<EOF
datasources:
  - name: Prometheus
    url: http://{{ env "attr.unique.network.ip-address" }}:9090/prometheus
EOF          
      }
    }
  }
}