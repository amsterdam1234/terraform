resource "aws_route53_zone" "omer-amsterdam"{
  name = "omer-amsterdam.com"
}
#the next part is to get a registered domain

resource "aws_route53domains_registered_domain" "omer-amsterdam" {
  domain_name = aws_route53_zone.omer-amsterdam.name

  dynamic "name_server" {
    for_each = toset(aws_route53_zone.omer-amsterdam.name_servers)
    content {
      name = name_server.value
    }
  }
  auto_renew = false
  transfer_lock = false
}


resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.omer-amsterdam.zone_id
  name    = "omer-amsterdam.com"
  type    = "A"

  alias {
    name                   = aws_elb.omer-elb.dns_name
    zone_id                = aws_elb.omer-elb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "prometheus" {
  zone_id = aws_route53_zone.omer-amsterdam.zone_id
  name    = "prometheus.omer-amsterdam.com"
  type    = "A"
  ttl     = 300
  records = [aws_instance.bastion_promethues.public_ip]
}
