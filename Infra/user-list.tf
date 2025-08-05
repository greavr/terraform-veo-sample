# ----------------------------------------------------------------------------------------------------------------------
# User Variable List
# ----------------------------------------------------------------------------------------------------------------------

variable "user_list" {
    type = list(object({
        email = string
        region = string
        })
    )
    default = [{
            region = "europe-west2"
            email = "admin@rgreaves.altostrat.com"
        },
        {
            region = "us-west1"
            email = "admin@rgreaves.altostrat.com"
        },
        {
            region = "us-east1"
            email = "admin@rgreaves.altostrat.com"
        },
        {
            region = "us-east1"
            email = "abe@rgreaves.altostrat.com"
        }
        ]
}