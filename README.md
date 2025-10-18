# 🛒 Retail E-Commerce Migration (AWS Cloud Project)

**Project:** Retail Static Website Cloud Deployment using AWS & Terraform  
**Team:** Hardik, Andrea, Daniel, Joseph – 2025 CCA UG (Group 1)  
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

Here’s your **GitHub-ready** version of the **Deployment Instructions**, formatted with ✅ emojis and spacing for clean readability in Markdown:

---

## 🚀 Deployment Instructions (AWS Academy Sandbox)

### **0. Clone the Repository (Get the Code)**

Cloning ensures you are working with the latest Terraform and website files.

**Option A — HTTPS**

```bash
git clone https://github.com/hazzymazzy/retail-ecommerce-migration.git
cd retail-ecommerce-migration/terraform
```

**Option B — SSH** *(optional, only if GitHub SSH keys are set up)*

```bash
git clone git@github.com:hazzymazzy/retail-ecommerce-migration.git
cd retail-ecommerce-migration/terraform
```

> 💡 **Note:** SSH is **only needed for pushing changes back to GitHub**.
> For assessment, only `terraform apply` is required — **SSH is not needed**.

---

### **(Optional for CloudShell Users) Set AWS Region**

```bash
export AWS_REGION=ap-southeast-2
```

> Ensures deployment happens in the correct AWS Academy Sandbox region (**Sydney**).

---

### ⚙ **(Only if Terraform is not installed) Install Terraform**

```bash
sudo yum -y install yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# Verify installation:
terraform -version
```

> ⚠ Run this step **only if** `terraform` command is not available.

---

### **1. Initialise and Deploy**

```bash
terraform init
```

> Downloads providers and sets up the working directory.

```bash
terraform plan -out=tfplan
```

> Shows what Terraform will create before applying.

```bash
terraform apply -auto-approve tfplan
```

> Deploys **S3, CloudFront, IAM roles, and OAC** automatically.

---

### **2. Retrieve Website URL**

```bash
terraform output -raw cloudfront_url
```

> Retrieves the **live CloudFront URL** for the deployed website.

> ⏳ **CloudFront may take 2–4 minutes** to fully propagate.

---

### **3. Destroy Resources (To Free AWS Sandbox Credits)**

```bash
terraform destroy -auto-approve
```

> Safely removes AWS resources to stay within **sandbox credit limits**.

---

### **Website Footer Credit**

The deployed static site displays this footer for attribution:

> **Built by Hardik, Andrea, Daniel, Joseph — 2025 CCA UG**

---

### **GitHub Tracking (Optional — For Development Logging Only)**

```bash
./scripts/update-readme-url.sh
```

> ⚠ **Not required for marking** — used only to log CloudFront URLs during development.

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

