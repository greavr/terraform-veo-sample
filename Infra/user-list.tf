# ----------------------------------------------------------------------------------------------------------------------
# Group Variable List
# ----------------------------------------------------------------------------------------------------------------------

variable "group_list" {
    type = list(object({
        email = string
        region = string
        })
    )
    default = [{
            region = "northamerica-northeast2"
            email = "vpc-test@rgreaves.altostrat.com"
        },
        {
            region = "us-east4"
            email = "vpc-test@rgreaves.altostrat.com"
        },
        {
            region = "southamerica-east1"
            email = "vpc-test@rgreaves.altostrat.com"
        }
        ]
}