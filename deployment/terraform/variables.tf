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