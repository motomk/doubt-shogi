variable "project_id" {
  type    = string
  default = "portfolio-420211"
}

variable "region" {
  type    = string
  default = "asia-northeast1"
}

variable "domain" {
  description = "The site's own domain, a subdomain of enei-shogi.com (DNS at Cloudflare)"
  type        = string
  default     = "doubt.enei-shogi.com"
}

variable "hosting_site_id" {
  description = "Firebase Hosting site, also the <id>.web.app address; must match frontend/firebase.json"
  type        = string
  default     = "doubt-shogi"
}

variable "github_repository" {
  description = "owner/name of the repository whose main branch may deploy"
  type        = string
  default     = "motomk/doubt-shogi"
}

variable "github_pool_id" {
  description = "Workload Identity pool for GitHub Actions, made by 燕衛将棋's Terraform"
  type        = string
  default     = "github"
}

variable "max_instances" {
  description = "Upper bound on API instances, which bounds the cost"
  type        = number
  default     = 2
}
