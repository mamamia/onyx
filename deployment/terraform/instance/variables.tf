variable "project" {
  description = "GCP project name"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "instance_name" {
  description = "Name of the instance"
  type        = string
}

variable "onyx_repository_url" {
  description = "URL to use when cloning Onyx"
  type        = string
  default     = "https://github.com/onyx-dot-app/onyx.git"
}

variable "onyx_branch_name" {
  description = "Branch name to use when cloning Onyx"
  type        = string
  default     = "main"
}

variable "service_account_email" {
  description = "Service account assigned to the instance. Optional. If not set, uses the default Compute Engine service account for the project."
  type        = string
  nullable    = true
  default     = null
}

variable "subdomain" {
  description = "Subdomain of mamamia.com.au pointing to this instance (configured in CloudFlare)"
  type        = string
}

variable "google_oauth_client_id" {
  description = "Google OAuth client ID used for instance auth"
  type        = string
}

variable "google_oauth_client_secret" {
  description = "Google OAuth secret used for instance auth"
  sensitive   = true
}

variable "anthropic_api_key" {
  description = "API key for Claude"
  type        = string
  sensitive   = true
}

variable "bing_api_key" {
  description = "API for Bing (used for Onyx InternetSearchTool)"
  type        = string
  sensitive   = true
}