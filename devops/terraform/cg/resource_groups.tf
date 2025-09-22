resource "aws_resourcegroups_group" "resourcegroups" {
  name        = "${replace(var.common_tags["Project"], " ", "-")}-${replace(var.common_tags["Environment"], " ", "-")}-rg"
  description = "Resource group for ${replace(var.common_tags["Project"], " ", "-")} in ${replace(var.common_tags["Environment"], " ", "-")} environment."

  resource_query {
    query = jsonencode({
      "ResourceTypeFilters": [
        "AWS::EC2::Instance"
      ],
      "TagFilters": [
        {
          "Key": "Environment",
          "Values": [var.common_tags["Environment"]]
        },
        {
          "Key": "OS",
          "Values": [var.OS]
        }
      ]
    })
  }

  tags = merge(var.common_tags, {
    Name = "${replace(var.common_tags["Project"], " ", "-")}-${replace(var.common_tags["Environment"], " ", "-")}-rg",
    OS   = var.OS
  })
}
