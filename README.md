# 🛒 Retail E-Commerce Migration (AWS Cloud Project)

**Project:** Retail Static Website Cloud Deployment using AWS & Terraform  
**Team:** Hardik, Andrea, Daniel, Joseph – 2025 CCA UG (Group 5)  
**Instructor:** Essam  
**Unit:** Cloud Computing Architecting (AWS Academy)

---

This project deploys a **static retail website** to **Amazon S3** and delivers it globally via **CloudFront CDN**, fully provisioned using **Terraform (Infrastructure as Code)**.

✅ **Single-file Terraform deployment (`main.tf`)** — easy for assessment and reproducibility  
✅ **No manual AWS Console configuration** — full IaC automation  
✅ **Live CloudFront URL generated automatically on deploy** — ready for showcase  
✅ Aligned with AWS Well-Architected principles: **Security, Cost Efficiency, Performance, Reliability, and Operational Excellence**

---

## Live Demo (Team Deployment Instance)

CloudFront URL: **https://d1gd53n8lrwf08.cloudfront.net**

> ℹ **Note:** This URL was generated from our team deployment.  
> When `terraform apply` is executed in the AWS Academy Sandbox, **a new CloudFront URL will be generated automatically**.  
> This tracking is for **logging and demonstration purposes only.**.

---

## Project Architecture Overview

The full architecture explanation with diagram is included in the **report submission**.

> **See detailed architecture and justification in the report** (CloudFront → OAC → Private S3 Bucket → Optional Glacier Lifecycle)

---

## Deployment Instructions (AWS Academy Sandbox)

### **0. Clone the Repository (Get the Code)**  
Cloning ensures you are working with the **latest Terraform and website files**.

**Option A — HTTPS**
```bash
git clone https://github.com/hazzymazzy/retail-ecommerce-migration.git
cd retail-ecommerce-migration/terraform
```

**Option B — SSH** (only if SSH keys are configured)
```bash
git clone git@github.com:hazzymazzy/retail-ecommerce-migration.git
cd retail-ecommerce-migration/terraform
```
> **Note:** SSH is **optional** and only used for pushing changes back to GitHub.  
> **Assessment does not require SSH** — only `terraform apply` is needed to deploy.

---

### **(Optional) Set AWS Region for CloudShell**
```bash
export AWS_REGION=ap-southeast-2
```
> Ensures deployment happens in the correct AWS Academy Sandbox region (Sydney).

---

### **1. Initialise and Deploy**
```bash
terraform init
```
> Prepares Terraform by downloading the AWS provider.

```bash
terraform plan -out=tfplan
```
> Shows the resources that will be created before deploying.

```bash
terraform apply -auto-approve tfplan
```
> Deploys S3, CloudFront, IAM roles, and OAC automatically.

---

### **2. Retrieve Website URL**
```bash
terraform output -raw cloudfront_url
```
> Fetches the live CloudFront URL for the deployed site.

> CloudFront may take **2–4 minutes** to fully propagate after deployment.

---

### **3. Destroy Resources (To Free AWS Sandbox Credits)**
```bash
terraform destroy -auto-approve
```
> Deprovisions all AWS resources to avoid hitting sandbox limits.



---

## Website Footer Credit

The deployed static website displays this footer for project attribution:

> **Built by Hardik, Andrea, Daniel, Joseph — 2025 CCA UG**

---

## GitHub Tracking (Optional — For Development Logging Only)

A helper script is included for internal use to log CloudFront URLs into README:

```bash
./scripts/update-readme-url.sh
```

> ⚠ This script is **not required for marking** — it was only used during development to keep version history clean.

---

## AWS Well-Architected Pillar Summary (Quick Justification)

| AWS Pillar | Implementation Insight |
|-----------|------------------------|
| **Security** | Private S3 bucket + OAC + HTTPS-only CloudFront |
| **Cost Optimisation** | Serverless static hosting — no EC2 or backend costs |
| **Performance Efficiency** | CloudFront global CDN caching reduces latency |
| **Reliability** | Versioned S3 + Terraform IaC = predictable redeployment |
| **Operational Excellence** | Automated deployment with repeatable infrastructure state |

---

## Team Submission Note

Submitted as part of **AWS Academy – Cloud Computing Architecting (CCA UG)**  
**Group 5** — Hardik, Andrea, Daniel, and Joseph — **2025**

