output "Load_Balancer_Address" {
  value = "http://${aws_lb.consul.dns_name}:4646"
}

output "CONSUL_HTTP_ADDR_variable" {
    value = "export CONSUL_HTTP_ADDR=http://${aws_lb.consul.dns_name}:8500"
}
output "NOMAD_ADDR_variable" {
    value = "export NOMAD_ADDR=http://${aws_lb.consul.dns_name}:4646"
}