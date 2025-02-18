module "onyx_staging" {
  source = "./instance"

  project             = "mamamia-pwa"
  region              = "us-central1"
  zone                = "us-central1-a"
  instance_name       = "onyx-staging"
  onyx_repository_url = "https://github.com/mamamia/onyx.git"
  subdomain           = "ai-staging"

  google_oauth_client_id     = var.google_oauth_client_id
  google_oauth_client_secret = var.google_oauth_client_secret
  anthropic_api_key          = var.anthropic_api_key
  bing_api_key               = var.bing_api_key
}

module "test" {
  source = "./instance"

  project             = "mamamia-pwa"
  region              = "us-central1"
  zone                = "us-central1-a"
  instance_name       = "onyx-test"
  onyx_repository_url = "https://github.com/mamamia/onyx.git"
  onyx_branch_name    = "upstream-release"
  subdomain           = "ai-test"

  google_oauth_client_id     = var.google_oauth_client_id
  google_oauth_client_secret = var.google_oauth_client_secret
  anthropic_api_key          = var.anthropic_api_key
  bing_api_key               = var.bing_api_key
}