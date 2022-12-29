job "dnsperf_consul_docker" {

  datacenters = ["dc1"]
  type = "batch"

  // parameterized {

  // }

  group "dnsperf" {
    count = 1

    task "dnsperf" {
      driver = "docker"

      config {
        network_mode = "host"
        image = "nickwales/dnsperf:0.0.1"
        // args  = [
        //   "-d", "local/records.txt",
        //   "-n", "5",
        //   "-c", "10",
        //   "-p", "5353"
        //   // "-Q", "45000"
        // ]
        volumes = [
          "local/records.txt:/opt/records.txt"
        ]
      }

      env {
        DNS_SERVER_ADDR = "127.0.0.1"
        DNS_SERVER_PORT = "5353"
        RUN_COUNT       = "1"

      }

      resources {
        cpu    = 1000 # MHz
        memory = 101 # MB
      }                    

      template {
        destination = "${NOMAD_TASK_DIR}/records.txt"
        data        = <<EOF
consul.service.consul A
grafana.service.consul A
prometheus.service.consul A
postgres.service.consul A
monitoring.node.consul A
EOF
      }
    }
  }
}
