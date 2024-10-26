data "aws_route53_zone" "hz" {
  name = var.hosted_zone  
}



resource "aws_route53_record" "tm_subdomain" {
  zone_id = data.aws_route53_zone.hz.zone_id
  name    = var.subdomain_name
  type    = "CNAME"
  
 
  ttl    = 300
  records = [var.dns_name]
}


