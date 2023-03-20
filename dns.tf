locals {
  application_fqdn = var.subdomain != null && local.load_balancer != null ? replace(
    "${var.subdomain.name}.${data.aws_route53_zone.current[0].name}", "/[.]$/", "",
  ) : null

  certificate_arn   = var.create_cert ? var.create_lb && var.certificate_arn != null ? var.certificate_arn : var.protocol == "HTTP" ? aws_acm_certificate.default[0].arn : null : null
  certificate_count = var.create_cert ? var.create_lb && var.certificate_arn == null && var.subdomain != null && var.protocol == "HTTP" ? local.load_balancer_count : 0 : 0
}

data "aws_route53_zone" "current" {
  count   = var.subdomain != null ? local.load_balancer_count : 0
  zone_id = var.subdomain.zone_id
}

# resource "aws_route53_record" "default" {
#   count   = var.subdomain != null ? local.load_balancer_count : 0
#   zone_id = data.aws_route53_zone.current[0].zone_id
#   name    = local.application_fqdn
#   type    = "CNAME"
#   ttl     = "5"
#   records = [aws_lb.default[0].dns_name]
# }

resource "aws_route53_record" "default" {
  count   = var.subdomain != null ? local.load_balancer_count : 0
  zone_id = data.aws_route53_zone.current[0].zone_id
  name    = local.application_fqdn
  type    = "A"

  alias {
    name                   = aws_lb.default[0].dns_name
    zone_id                = aws_lb.default[0].zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "default" {
  count             = local.certificate_count
  domain_name       = local.application_fqdn
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  count   = local.certificate_count
  name    = aws_acm_certificate.default[count.index].domain_validation_options.*.resource_record_name[0]
  records = [aws_acm_certificate.default[count.index].domain_validation_options.*.resource_record_value[0]]
  type    = aws_acm_certificate.default[count.index].domain_validation_options.*.resource_record_type[0]
  zone_id = data.aws_route53_zone.current[0].zone_id
  ttl     = 60
}

resource "aws_acm_certificate_validation" "default" {
  count                   = local.certificate_count
  certificate_arn         = local.certificate_arn
  validation_record_fqdns = [aws_route53_record.validation[count.index].fqdn]
}
