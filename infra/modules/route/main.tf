data "aws_route53_zone" "this" {
  name         = "nagendraops.info"
  private_zone = false
}


resource "aws_route53_record" "image-app" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "image-app.nagendraops.info"
  type    = "A"

  alias {
    name                   = module.eks.cluster_endpoint
    zone_id                = module.eks.cluster_hosted_zone_id
    evaluate_target_health = true
  }
} 


resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "app.nagendraops.info"
  type    = "A"
  ttl     = 300
  records = ["YOUR_PUBLIC_IP_OR_ENDPOINT"]
}
