# Fetch Route 53 Zone
data "aws_route53_zone" "main" {
  name         = "nagendraops.info"  # change if needed
  private_zone = false
}

# ACM Certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = "gallery.nagendraops.info"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "gallery-cert"
  }
}

# Convert validation_options to a list to extract records
resource "aws_route53_record" "cert_validation" {
  zone_id = data.aws_route53_zone.main.zone_id

  name    = element(tolist(aws_acm_certificate.cert.domain_validation_options), 0).resource_record_name
  type    = element(tolist(aws_acm_certificate.cert.domain_validation_options), 0).resource_record_type
  records = [element(tolist(aws_acm_certificate.cert.domain_validation_options), 0).resource_record_value]
  ttl     = 60
}

# Validate the certificate
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
