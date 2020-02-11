variable key_file {
    type        = "string"
    default     = ""
    description = "The FULL path to your Service Account JSON file"
}

variable project {
    type        = "string"
    default     = ""
    description = "Your Project ID"
}

variable region {
    type        = "string"
    default     = ""
    description = "The region you'd like to use for resources"
}

variable zone {
    type        = "string"
    default     = ""
    description = "The zone you would like to use for resources. MUST be included in your chosen region!"
}

variable bucket_name {
    type        = "string"
    default     = ""
    description = "The pre-existing bucket to store your Cloud Function Python code"
}
