# 🚀 Staff SRE / DevSecOps Portfolio

> **A Hybrid-Cloud, GitOps-driven Microservices Platform running on Local Infrastructure.**
> *Designed to demonstrate architectural patterns for Resilience, Security, and Observability without Cloud Provider costs.*

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Kubernetes](https://img.shields.io/badge/kubernetes-v1.29-326ce5.svg)
![ArgoCD](https://img.shields.io/badge/gitops-argocd-orange.svg)
![Terraform](https://img.shields.io/badge/iac-terraform-purple.svg)

---

## 🏗️ High-Level Architecture

This platform simulates a real-world Enterprise environment using **Kind (Kubernetes in Docker)** and **Cloudflare Tunnels** to expose services securely. It implements a strictly declarative **GitOps** workflow.

```mermaid
flowchart TD
    User([End User / Traffic]) -->|HTTPS| CF[Cloudflare Tunnel]
    Engineer([Staff Engineer]) -->|git push| GH{GitHub Repo}

    subgraph CI ["CI Pipeline (GitHub Actions)"]
        GH -->|Trigger| GHA[Build & Test]
        GHA -->|Scan CVEs| Trivy[Trivy Security]
        Trivy -- Pass --> GHCR[GitHub Container Registry]
        Trivy -- Fail --> Block[❌ Block Deployment]
    end

    subgraph Cluster ["Cluster (Local Kind)"]
        CF -->|Tunnel| Ingress[NGINX Ingress]
        
        subgraph ControlPlane ["Control Plane"]
            ArgoCD[ArgoCD Controller]
            Kyverno[Kyverno Policy Engine]
        end

        subgraph Observability ["Observability"]
            Prom[Prometheus] -->|Scrape| Pods
            Graf[Grafana] -->|Query| Prom
        end

        subgraph Workloads ["Workloads (Namespaces)"]
            DevEnv[DEV Env]
            QAEnv[QA Env]
            ProdEnv[PROD Env HA]
        end

        ArgoCD -->|Sync| GH
        ArgoCD -->|Deploy| DevEnv & QAEnv & ProdEnv
        Ingress -->|Route| ProdEnv
        Kyverno -->|Enforce Policies| Pods
    end
---
## 🛠️ The Tech Stack
Domain	Tool	Why I Chose It (Architectural Decision)
Orchestration	Kind (Kubernetes in Docker)	Simulates a full K8s API locally, enabling zero-cost infrastructure iteration while maintaining API compatibility with GKE/EKS.
GitOps	ArgoCD	Implements the "Pull Model" for deployment. Ensures the cluster state always matches Git, preventing configuration drift.
CI / Build	GitHub Actions	Tightly integrated with the source code. Allows for event-driven triggers (Push/PR) to build Docker images automatically.
Security (Left)	Trivy	Scans container images for CVEs before push. Configured to break the build on CRITICAL vulnerabilities.
Security (Right)	Kyverno	Policy-as-Code engine. Enforces runtime security (e.g., "Disallow Root User") natively within the cluster.
Observability	Prometheus & Grafana	Industry standard. Configured with ServiceMonitors to scrape NGINX and cAdvisor metrics for Golden Signals (Latency, Traffic, Errors).
IaC	Terraform	Manages the Governance of the repository itself (Branch Protection, Repo Settings) to treat "Governance as Code."
---
Built by Amarjyoti Lahkar

```
