data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_wafv2_web_acl" "demo" {
  name = "DemoEndpointProtection"
    scope = "REGIONAL"
    default_action {
        allow {}
}
visibility_config {
  cloudwatch_metrics_enabled = true
  metric_name = "DemoWaf"
  sampled_requests_enabled = true
}
rule {
  name = "BlockSQLi"
  priority = 1
  statement {
    sqli_match_statement {
      field_to_match {
        uri_path {}
        }
        text_transformation {
          priority = 0
          type = "URL_DECODE"
        }
      }
    }
    action {
      block {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name  ="BlockSQLi"
      sampled_requests_enabled = true
    }
  }
}
resource "aws_wafv2_web_acl_association" "demo" {
  resource_arn = var.alb_arn
  web_acl_arn = aws_wafv2_web_acl.demo.arn
}




