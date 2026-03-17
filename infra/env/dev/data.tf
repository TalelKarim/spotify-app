data "aws_route53_zone" "main" {
  name         = "${var.root_domain_name}."
  private_zone = false
}