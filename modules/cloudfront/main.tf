resource "aws_cloudfront_origin_access_control" "asset" {
  count = var.enabled && var.enable_asset_origin ? 1 : 0

  name                              = "${var.origin_id}-asset-oac"
  description                       = "OAC for ${var.origin_id} asset origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  count = var.enabled ? 1 : 0

  enabled         = true
  is_ipv6_enabled = true
  comment         = var.comment
  price_class     = var.price_class
  aliases         = var.aliases

  origin {
    domain_name = var.origin_domain_name
    origin_id   = var.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = var.origin_protocol_policy
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  dynamic "origin" {
    for_each = var.enable_asset_origin ? [1] : []
    content {
      domain_name = var.asset_origin_domain_name
      origin_id   = var.asset_origin_id

      origin_access_control_id = aws_cloudfront_origin_access_control.asset[0].id

      s3_origin_config {
        origin_access_identity = ""
      }
    }
  }

  default_cache_behavior {
    target_origin_id       = var.origin_id
    viewer_protocol_policy = var.viewer_protocol_policy
    allowed_methods        = var.allowed_methods
    cached_methods         = var.cached_methods
    compress               = var.compress

    forwarded_values {
      query_string = var.forward_query_string

      cookies {
        forward = var.cookie_forward
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.enable_asset_origin ? [1] : []
    content {
      path_pattern           = var.asset_path_pattern
      target_origin_id       = var.asset_origin_id
      viewer_protocol_policy = var.asset_viewer_protocol_policy
      allowed_methods        = var.asset_allowed_methods
      cached_methods         = var.asset_cached_methods
      compress               = var.asset_compress
      min_ttl                = var.asset_min_ttl
      default_ttl            = var.asset_default_ttl
      max_ttl                = var.asset_max_ttl

      forwarded_values {
        query_string = var.asset_forward_query_string

        cookies {
          forward = var.asset_cookie_forward
        }
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = var.minimum_protocol_version
  }
}
