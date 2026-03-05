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

```
---

Built by Amarjyoti Lahkar
