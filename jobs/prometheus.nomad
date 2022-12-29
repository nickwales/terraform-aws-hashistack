job "prometheus" {

  region      = "global"
  datacenters = ["dc1"]

  constraint {
      attribute = "${node.class}"
      value = "monitoring"
  }

  group "prometheus" {

    network {
      port "http" {
        static = 9090
        to = 9090
      }
    }

    ephemeral_disk {
      migrate = true
      size    = 1000
      sticky  = true
    }

    service {
      name = "prometheus"
      port = "9090" 
      tags = ["monitoring"]
      
      check {
        type     = "http"
        name     = "prometheus"
        path     = "/prometheus/-/healthy"
        interval = "30s"
        timeout  = "10s"
        port     = "http"
      }

    }

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus:v2.30.2"
        args = [
          "--config.file=/etc/prometheus/config/prometheus.yml",
          "--storage.tsdb.path=/prometheus/data",
          "--web.listen-address=0.0.0.0:9090",
          "--web.external-url=/prometheus/",
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles"
        ]
        volumes = [
          "local/config:/etc/prometheus/config"
        ]
        ports = ["http"]
      }
    
      template {
        data = <<EOH
---
global:
  scrape_interval: 30s
  evaluation_interval: 3s

rule_files:
  - rules.yml

alerting:
 alertmanagers:
    - consul_sd_configs:
      - server: {{ env "attr.unique.network.ip-address" }}:8500
        services:
        - alertmanager

scrape_configs:
  - job_name: "dnsmasq"
    static_configs:
      - targets:
{{- range nodes }}
        - {{ .Address }}:9153{{- end }}      
  - job_name: 'self'
    static_configs:
    - targets:
{{- range nodes }}
      - {{ .Address }}:9100{{- end }}
  - job_name: prometheus
    static_configs:
    - targets:
      - 0.0.0.0:9090
  - job_name: "nomad_server"
    metrics_path: "/v1/metrics"
    params:
      format:
      - "prometheus"
    consul_sd_configs:
    - server: "{{ env "attr.unique.network.ip-address" }}:8500"
      datacenter: dc1
      services:
        - "nomad"
      tags:
        - "http"
  - job_name: "nomad_client"
    metrics_path: "/v1/metrics"
    params:
      format:
      - "prometheus"
    consul_sd_configs:
    - server: "{{ env "attr.unique.network.ip-address" }}:8500"
      datacenter: dc1
      services:
        - "nomad-client"     
  - job_name: "consul_server"
    metrics_path: "/v1/agent/metrics"
    params:
      format:
      - "prometheus"
    static_configs:
    - targets:
  {{- range service "consul" }}
      - {{ .Address }}:8500{{- end }}
  - job_name: "consul_client"
    metrics_path: "/v1/agent/metrics"
    params:
      format:
      - "prometheus"
    static_configs:
    - targets:
  {{- range service "nomad-client" }}
      - {{ .Address }}:8500{{- end }}      



EOH

        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/prometheus.yml"
      }

      resources {
        cpu    = 501
        memory = 256
      }
    }
  }
}