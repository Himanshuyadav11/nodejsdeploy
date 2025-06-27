# Outputs
output "vpc_id" {
  value = aws_vpc.dev_vpc.id
}

output "jenkins_public_ip" {
  description = "Public IP of Jenkins instance"
  value       = aws_eip.jenkins_eip.public_ip
}

output "sonarqube_public_ip" {
  description = "Public IP of SonarQube instance"
  value       = aws_eip.sonarqube_eip.public_ip
}

output "k8s_master_public_ip" {
  description = "Public IP of K8s Master instance"
  value       = aws_eip.k8s_master_eip.public_ip
}

output "k8s_worker_public_ips" {
  description = "Public IPs of K8s Worker instances"
  value       = [for eip in aws_eip.k8s_worker_eip : eip.public_ip]
}
