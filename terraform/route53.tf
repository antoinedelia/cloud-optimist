data "aws_route53_zone" "zone" {
  name         = var.base_domain_name
  private_zone = false
}

resource "aws_route53_record" "record_certificate" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
}

resource "aws_route53_record" "record_cloudfront" {
  allow_overwrite = true
  name            = var.domain_name
  type            = "A"
  zone_id         = data.aws_route53_zone.zone.zone_id

  alias {
    name                   = aws_cloudfront_distribution.dist.domain_name
    zone_id                = aws_cloudfront_distribution.dist.hosted_zone_id
    evaluate_target_health = true
  }
}