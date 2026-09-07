variable "project_id" {
  description = "The GCP Project ID where the repositories are created"
  type        = string
}

variable "region" {
  description = "The region for the Artifact Registry repositories"
  type        = string
}

variable "repositories" {
  description = "Map of repository names to create"
  type        = map(string)
}
