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
            region = "us-west1"
            email = "vpc-test@rgreaves.altostrat.com"
        },
        {
            region = "us-east4"
            email = "vpc-test@rgreaves.altostrat.com"
        },
        {
            region = "southamerica-east1"
            email = "vpc-test@rgreaves.altostrat.com"
        },
        {
            region = "southamerica-west1"
            email = "vpc-test@rgreaves.altostrat.com"
        },
        {
            region = "northamerica-south1"
            email = "vpc-test@rgreaves.altostrat.com"
        },
        {
            region = "northamerica-northeast2"
            email = "vpc-test@rgreaves.altostrat.com"
        },
        {
            region = "europe-west2"
            email = "vpc-test@rgreaves.altostrat.com"
        },
        {
            region = "europe-west4"
            email = "vpc-test@rgreaves.altostrat.com"
        },
        {
            region = "asia-south2"
            email = "vpc-test@rgreaves.altostrat.com"
        },
        {
            region = "asia-east2"
            email = "vpc-test@rgreaves.altostrat.com"
        },
        {
            region = "asia-northeast1"
            email = "vpc-test@rgreaves.altostrat.com"
        },
        {
            region = "australia-southeast1"
            email = "vpc-test@rgreaves.altostrat.com"
        }
        ]
}