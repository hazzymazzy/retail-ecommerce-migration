# 🛒 Retail E-Commerce Migration (AWS Cloud Project)

**Project:** Retail E-Commerce Cloud Migration  
**Maintained by:** *Group 5 – Smart Retail Cloud Project, University of Canberra (2025)*  
**Members:** [Add other group member names here]  
**Instructor:** Essam  
**Unit:** Cloud Computing Architecting (AWS Academy)

---

Deploys a public static website to Amazon S3 using Terraform and serves it securely via CloudFront.  
This project demonstrates **Infrastructure as Code (IaC)**, **automation**, and **AWS best practices** for **scalable, cost-efficient web hosting** in a **sandbox-safe** environment.

---

## Project Architecture Overview

### **Design Summary**

The project implements a secure, high-availability architecture for hosting a static retail e-commerce website using AWS managed services.  
It highlights **automation (Terraform)**, **security (CloudFront OAC)**, and **scalability (S3 + CDN)** under the **AWS Well-Architected Framework**.

### **Key Components**

| Component | Description |
|------------|-------------|
| **S3 Bucket (Private)** | Hosts static site files (`index.html`, `error.html`) with versioning and lifecycle rules to archive to Glacier after 30 days. |
| **CloudFront (OAC Enabled)** | Global CDN distributing site content securely with HTTPS and signed access. |
| **Origin Access Control (OAC)** | Restricts direct public S3 access, allowing only CloudFront to fetch content. |
| **Terraform (IaC)** | Defines and provisions all infrastructure automatically. |
| **IAM Policies (Least Privilege)** | Enforces fine-grained permissions and compliance with AWS sandbox restrictions. |

### **High-Level Architecture Diagram**

```

+---------------------------+
|        User Browser       |
|     (HTTPS via CDN)       |
+-------------+-------------+
|
v
+---------------------------+
|      AWS CloudFront       |
|   Origin Access Control   |
+-------------+-------------+
|
v
+---------------------------+
|      Amazon S3 Bucket     |
|  (Static Website Hosting) |
+-------------+-------------+
|
v
+---------------------------+
|       AWS Glacier         |
| (Archived Object Storage) |
+---------------------------+

````

> **Key Benefits:**  
> - Improved **availability** through CDN caching  
> - Enhanced **security** with private S3 + OAC  
> - Automated **infrastructure reproducibility** via Terraform  
> - Cost-optimised lifecycle management using Glacier transitions  

---

## How to deploy (one person runs)

1) Launch **AWS Academy Sandbox** → open **AWS Console (Sydney)**.  
2) (If using **CloudShell**) install Terraform or run locally.  
3) Clone this repo and run:
   ```bash
   cd terraform
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
```` 4. Copy the `website_endpoint` from Terraform output and open it in your browser.

---

##  Destroy

```bash
cd terraform
terraform destroy
```

---

## Notes

* Update `bucket_name_suffix` in `variables.tf` to make the bucket globally unique.
* Keep repo **private**. Never commit secrets or tfstate files.

---

## 🌐 Live demo

CloudFront: https://d1gd53n8lrwf08.cloudfront.net

---

# Starting a New AWS Sandbox/CloudShell Session (Team Guide)

CloudShell VMs reset between sessions, so do these steps whenever you start a new session.
If you’re **brand new** to this repo, follow **Step 1** once, then use **Step 2** every session.

---

## 0️Prereqs (AWS Academy CloudShell)

* Log in to AWS Academy → open **CloudShell** (top-right terminal icon).
* Ensure you’re in the **Sydney** region or export manually:

  ```bash
  export AWS_REGION=ap-southeast-2
  ```

---

## First-time repo & Git setup (one-time per machine)

> Skip this if already configured on your CloudShell or local machine.

```bash
# 1) Clone the repo
git clone https://github.com/hazzymazzy/retail-ecommerce-migration.git
cd retail-ecommerce-migration

# 2) Identify yourself
git config --global user.name  "Your Name"
git config --global user.email "your_uni_email@uni.canberra.edu.au"

# 3) Set up SSH (no password prompts)
ssh-keygen -t ed25519 -C "your_uni_email@uni.canberra.edu.au"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub  # paste into GitHub > Settings > SSH and GPG keys

# 4) Switch repo remote to SSH
git remote set-url origin git@github.com:hazzymazzy/retail-ecommerce-migration.git

# 5) Test authentication
ssh -T git@github.com
```

---

## Per-session quickstart (every new CloudShell session)

```bash
cd ~/retail-ecommerce-migration
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

git remote -v
ssh -T git@github.com
export AWS_REGION=ap-southeast-2
```

---

## Install Terraform (only if missing)

```bash
sudo yum -y install yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

terraform -version
which terraform
```

---

## Deploy the prototype (S3 + CloudFront via Terraform)

> Our working IaC is **single-file** at `terraform/main.tf`.

```bash
cd ~/retail-ecommerce-migration/terraform

# Clean old files if they exist
rm -f cloudfront.tf outputs.tf s3.tf variables.tf providers.tf

# Ensure site files exist
[ -f ../website/index.html ] || echo "<h1>Retail Store Demo</h1>" > ../website/index.html
[ -f ../website/error.html ] || echo "<h1>404</h1>" > ../website/error.html

terraform init -upgrade
terraform plan -out=tfplan
terraform apply -auto-approve tfplan

terraform output -raw cloudfront_url
```

> CloudFront may take 2–4 minutes to finish deployment.

---

## Update website content

```bash
nano ../website/index.html
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
```

---

## Clean up (important for shared labs)

```bash
cd ~/retail-ecommerce-migration/terraform
terraform destroy -auto-approve
```

---

## Commit & push changes back to GitHub

```bash
cd ~/retail-ecommerce-migration
printf '%s\n' \
'.terraform/' '.terraform.lock.hcl' \
'terraform.tfstate' 'terraform.tfstate.backup' '*.tfstate*' \
'crash.log' '*.tfplan' '.DS_Store' 'Thumbs.db' >> .gitignore

git add -A
git commit -m "Update site / Terraform config"
git push origin main
```

---

## Automatically Update the Live Demo URL (CloudFront link)

After each successful Terraform deployment, update the README automatically.

### Create the script (run once)

```bash
mkdir -p scripts
cat > scripts/update-readme-url.sh <<'EOS'
#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

CF_URL="$(terraform -chdir=terraform output -raw cloudfront_url 2>/dev/null || true)"
if [[ -z "${CF_URL:-}" ]]; then
  echo "No cloudfront_url output found. Run 'terraform apply' first." >&2
  exit 1
fi

if grep -q '^CloudFront:' README.md; then
  sed -i "s#^CloudFront: .*#CloudFront: ${CF_URL}#g" README.md
else
  printf "\n## Live demo\nCloudFront: %s\n" "$CF_URL" >> README.md
fi

git add README.md
git commit -m "docs: update Live Demo URL to ${CF_URL}" || true
git push origin main
echo "README updated → ${CF_URL}"
EOS
chmod +x scripts/update-readme-url.sh
```

### Use it (after every new deployment)

```bash
./scripts/update-readme-url.sh
```

> This ensures the GitHub README always shows the **latest CloudFront demo link*

---

## Troubleshooting

### `AccessDenied: s3:GetBucketObjectLockConfiguration`

Use the **single-file** Terraform version (`main.tf`). Remove old split files.

### `BucketAlreadyExists`

Change `bucket_name_suffix` in `main.tf` to a unique value.

### `Permission denied (publickey)` on Git push

Run:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh -T git@github.com
```

### “Duplicate output definition”

Remove leftovers:

```bash
cd terraform
rm -f cloudfront.tf outputs.tf s3.tf variables.tf
terraform init -upgrade
```

### Terraform stuck or confused?

```bash
rm -f terraform.tfstate terraform.tfstate.backup tfplan
terraform init -upgrade
```

---

✅ **This repository demonstrates practical AWS IaC skills (S3, CloudFront, Terraform, GitOps) aligned with AWS Well-Architected pillars — cost optimisation, reliability, performance, and security.**


