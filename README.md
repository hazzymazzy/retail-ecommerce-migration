# 🛒 Retail E-Commerce Migration (AWS Cloud Project)

**Project:** Retail Static Website Cloud Deployment using AWS & Terraform  
**Team:** Hardik, Andrea, Daniel, Joseph – 2025 CCA UG (Group 5)  
**Instructor:** Essam  
**Unit:** Cloud Computing Architecting (AWS Academy)

---

This project deploys a **static retail website** to **Amazon S3** and serves it globally via **CloudFront CDN**, fully provisioned using **Terraform (Infrastructure as Code)**.

✅ **Single-file Terraform setup (`main.tf`)** ensures easy assessment and reproducibility.  
✅ **No manual GitHub update required by tutor** — CloudFront URL logs are maintained only for tracking.  
✅ Aligned with **AWS Well-Architected Framework**: *Security, Cost Optimisation, Performance Efficiency, Reliability, and Operational Excellence.*

---

## 🌐 Live Demo (Team Deployment Instance)

CloudFront URL: **https://d1gd53n8lrwf08.cloudfront.net**

> ⚠ **Note for Assessment:** This URL reflects our deployed instance.  
> When **Terraform is applied in the AWS Academy Sandbox**, a **new CloudFront URL will be automatically generated** 

---

## Project Architecture Overview

### **Design Summary**

The architecture uses AWS managed services to host a globally distributed static retail site securely and cost-effectively.  
It highlights **automation with Terraform**, **CDN performance via CloudFront**, and **restricted S3 access using OAC (Origin Access Control).**

### **Core AWS Components**

| Component | Purpose |
|------------|--------|
| **S3 Bucket (Private)** | Stores static website assets (`index.html`, `404.html`) with versioning. |
| **CloudFront Distribution** | Delivers content globally with caching and HTTPS enforcement. |
| **Origin Access Control (OAC)** | Protects S3 by allowing only CloudFront access (no public S3 URLs). |
| **Terraform IaC** | Automates complete provisioning with a **single config file**. |
| **IAM Security Model** | Follows least privilege and AWS Sandbox security compliance. |

### **High-Level Architecture Diagram**

```
User → CloudFront (HTTPS, CDN, OAC) → Private S3 Bucket → Optional Glacier Archival
```

---

## Deployment Instructions (AWS Academy Sandbox)

### 1. Initialise and Deploy

```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
```

### 2. Retrieve URL

```bash
terraform output -raw cloudfront_url
```

Open the URL in a browser — *deployment takes around 2–4 minutes to propagate.*

---

## 🧼 Destroy Resources (To Release AWS Sandbox Credits)

```bash
terraform destroy -auto-approve
```

---

## 🛠 Website Content & Team Credit Line

The static website includes a **footer line** displaying:

> **Built by Hardik, Andrea, Daniel, Joseph — 2025 CCA UG**

This is visible at the bottom of `index.html`.

---

## GitHub Tracking (For Team History Only)

We maintain CloudFront deployment logs with a helper script:

```bash
./scripts/update-readme-url.sh
```

> ⚠ **This is not required for grading** — it just keeps our repo history consistent.

---

## AWS Well-Architected Pillar Alignment (Brief Justification)

| Pillar | Applied Strategy |
|--------|-----------------|
| **Security** | Private S3 + CloudFront OAC + HTTPS enforced |
| **Cost Optimisation** | Static hosting via S3 & CDN — no EC2 or backend compute cost |
| **Performance Efficiency** | CloudFront edge caching for low-latency global access |
| **Reliability** | CDN reliability + versioned S3 means quick rollback |
| **Operational Excellence** | Terraform IaC = consistent, repeatable deployment with no console clicking |

---

## 👥 Team 
This project was developed as part of AWS Academy – Cloud Computing Architecting coursework, submitted by
Group 5: Hardik, Andrea, Daniel, and Joseph — 2025 CCA


