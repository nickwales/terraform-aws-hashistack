job "dnsperf_consul" {

  datacenters = ["dc1"]
  type = "batch"

  // parameterized {

  // }

  group "dnsperf" {
    count = 10

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    constraint {
      attribute = "${node.class}"
      value = "default"
    }

    task "dnsperf" {
      driver = "exec"

      config {
        command = "dnsperf"
        args  = [
          "-d", "local/records.txt",
          "-s", "127.0.0.1",
          "-n", "5000001",
          "-c", "10",
          "-p", "8600"
          // "-Q", "45000"
        ]
      }

      resources {
        cpu    = 1500 # MHz
        memory = 100 # MB
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
