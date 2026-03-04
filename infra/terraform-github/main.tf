terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  # It automatically reads the GITHUB_TOKEN environment variable
}

# 1. Define the Repository (We will import your existing one into this)
resource "github_repository" "portfolio" {
  name        = "sre-portfolio-boutique"
  description = "Staff SRE Portfolio: GitOps, DevSecOps, and Observability on Kubernetes"
  visibility  = "public"
  
  # Enable these features
  has_issues   = true
  has_projects = true
  has_wiki     = true
  
  allow_merge_commit = false
  allow_squash_merge = true
  allow_rebase_merge = false
}

# 2. Protect the 'main' branch (The DevSecOps Shield)
resource "github_branch_protection" "main" {
  repository_id = github_repository.portfolio.node_id
  pattern       = "main"

  # Force Push = Data Loss. We block it.
  allows_force_pushes = false
  
  # Prevent deletion of the main branch
  allows_deletions    = false

  # Require at least one check to pass (like our Trivy scan!) before merging
  # (Uncomment this later once we are fully confident in the pipeline)
  # required_status_checks {
  #   strict   = true
  #   contexts = ["build-scan-and-push"]
  # }
}
