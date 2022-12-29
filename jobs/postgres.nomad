job "postgres" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "service"

  constraint {
      attribute = "${node.class}"
      value = "monitoring"
  }

  group "postgres" {
      count = 1

    ephemeral_disk {
      migrate = true
      size    = 400
      sticky  = true
    }

    network {
      port "db" { 
        static = 5432
        to     = 5432
      }
    }

    service {
      name = "postgres"
      tags = ["db", "postgres"]
      port = "5432"

      check {
        name     = "alive"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
        port     = "db"
      }
    }        
    
    task "postgres" {
      driver = "docker"
      config {
        image = "postgres:14.6"
        ports = ["db"]
      }

      env {
        POSTGRES_USER     = "grafana"
        POSTGRES_PASSWORD = "grafana"
        POSTGRES_DB       = "grafana"
      }
            
      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
        cpu = 500
        memory = 256
      }
  
    }

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
  }

  update {
    max_parallel = 1
    min_healthy_time = "5s"
    healthy_deadline = "3m"
    auto_revert = false
    canary = 0
  }
}