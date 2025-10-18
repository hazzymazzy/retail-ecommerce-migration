---

# 🛒 Retail E-Commerce Migration (AWS Cloud Project)

**Project:** Retail Static Website Cloud Deployment using AWS & Terraform
**Team:** Hardik, Andrea, Daniel, Joseph — 2025 CCA UG (Group 1)
**Instructor:** Essam
**Unit:** Cloud Computing Architecting (AWS Academy)

---

This repo deploys a **static retail website** on **Amazon S3 (Website Hosting)** and serves it globally via **CloudFront CDN**, provisioned with **Terraform (IaC)**.

* ✅ Simple, self-contained Terraform in `terraform/`
* ✅ No SSH required for marking (SSH only needed if pushing code back to GitHub)
* ✅ CloudFront URL auto-output after deploy
* ✅ Optional **refresh script** to make S3 website & CDN show content immediately 

---

## Live Demo (Example)

> A CloudFront URL is created **per deployment** (e.g. `https://d1ttjr8nrj71ha.cloudfront.net`).
> Your URL will be different each time you run `terraform apply`.

---

## 🧭 Architecture Overview

**Design Summary:**
Static site files are stored in an **S3 website bucket** and distributed globally via **CloudFront**. Terraform builds the CDN and points it at the S3 Website endpoint. A small script (optional) enables website hosting, sets a public read policy (required for S3 *Website* endpoints), uploads the files, and invalidates CloudFront to show the site immediately.

**Core Components**

| Component                    | Purpose                                                                       |
| ---------------------------- | ----------------------------------------------------------------------------- |
| **S3 (Website Hosting)**     | Serves static files (`index.html`, `error.html`) via region website endpoint  |
| **CloudFront (CDN)**         | HTTPS, caching, global distribution, origin = S3 Website endpoint             |
| **Terraform (IaC)**          | Declarative deployment of CloudFront distribution & outputs                   |
| **Helper Script (optional)** | Ensures S3 website hosting + public policy + uploads files + CDN invalidation |

**Why not OAC/private S3 here?**
AWS Academy sandbox policies can block S3 features used by **private S3 + OAC**. Using **S3 Website Hosting** keeps the lab reliable while still demonstrating IaC + CDN patterns.


---

## Deployment Instructions (AWS Academy CloudShell)

> No SSH required for marking. Use CloudShell in **ap-southeast-2 (Sydney)**.

### 0) Clone the Repository

```bash
git clone https://github.com/hazzymazzy/retail-ecommerce-migration.git
cd retail-ecommerce-migration/terraform
```

### 1) (If missing) Install Terraform once per session

```bash
# Amazon Linux / CloudShell:
sudo dnf -y install unzip || sudo yum -y install unzip
TF_VERSION=1.7.5
cd /tmp
curl -fsSLO "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
unzip -o "terraform_${TF_VERSION}_linux_amd64.zip"
sudo mv -f terraform /usr/local/bin/terraform
hash -r && terraform -version
```

### 2) Set Region (Sydney)

```bash
export AWS_REGION=ap-southeast-2
```

*Why:* ensures resources are deployed where the Academy sandbox credits and limits are expected.

### 3) Deploy CloudFront (Terraform)

```bash
cd ~/retail-ecommerce-migration/terraform
rm -rf .terraform && rm -f .terraform.lock.hcl tfplan terraform.tfstate terraform.tfstate.backup

terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan

# Get the URL Terraform outputs
terraform output -raw cloudfront_url
```

Open the printed URL (e.g. `https://xxxxxxx.cloudfront.net`).
If the page is blank or 403/404, run the optional **refresh** step below.

---

## Optional: Refresh Origin & CDN (1-minute helper)

> This makes the S3 Website endpoint **serve your files publicly** and forces CloudFront to refresh.

1. **Create the script**

```bash
mkdir -p ~/retail-ecommerce-migration/scripts
cat > ~/retail-ecommerce-migration/scripts/refresh-origin-and-cdn.sh <<'EOS'
#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG ---
REGION="${AWS_REGION:-ap-southeast-2}"
# Set this to the bucket name behind your S3 WEBSITE endpoint (not the CloudFront URL).
# If you followed the repo’s examples, this is the bucket you created for website hosting.
BUCKET="${BUCKET:-CHANGE_ME_BUCKET_NAME}"

# --- Derive distribution ID from Terraform output ---
TF_DIR="$(git rev-parse --show-toplevel 2>/dev/null)/terraform"
CF_DOMAIN="$(terraform -chdir="$TF_DIR" output -raw cloudfront_url | sed 's#^https://##')"
DIST_ID="$(aws cloudfront list-distributions \
  --query "DistributionList.Items[?DomainName=='$CF_DOMAIN'].Id | [0]" \
  --output text)"

echo "Region:      $REGION"
echo "Bucket:      $BUCKET"
echo "CF Domain:   $CF_DOMAIN"
echo "CF Dist ID:  $DIST_ID"

# --- Ensure S3 Website hosting + public read policy ---
aws s3 website "s3://$BUCKET" --index-document index.html --error-document error.html

aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false

cat > /tmp/policy.json <<JSON
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"PublicRead",
    "Effect":"Allow",
    "Principal":"*",
    "Action":["s3:GetObject"],
    "Resource":["arn:aws:s3:::$BUCKET/*"]
  }]
}
JSON
aws s3api put-bucket-policy --bucket "$BUCKET" --policy file:///tmp/policy.json --region "$REGION"

# --- Upload site files ---
SITE_DIR="$(git rev-parse --show-toplevel)/website"
aws s3 sync "$SITE_DIR" "s3://$BUCKET" --delete

# --- Invalidate CDN so content shows immediately ---
aws cloudfront create-invalidation --distribution-id "$DIST_ID" --paths "/*" >/dev/null

echo "Refresh complete. Open: https://$CF_DOMAIN"
EOS
chmod +x ~/retail-ecommerce-migration/scripts/refresh-origin-and-cdn.sh
```

2. **Run it (set your bucket name first!)**

```bash
export AWS_REGION=ap-southeast-2
export BUCKET=<your-website-bucket-name>   # e.g. retail-demo-1760753429
~/retail-ecommerce-migration/scripts/refresh-origin-and-cdn.sh
```

> Re-open your CloudFront URL. It should now display your site immediately.

---

## Destroy (free sandbox credits)

```bash
cd ~/retail-ecommerce-migration/terraform
terraform destroy -auto-approve
```

---

## Repo Layout

```
.
├─ website/                 # index.html, error.html, static assets
├─ terraform/
│  ├─ providers.tf          # AWS provider (Sydney)
│  ├─ variables.tf          # region & common tags
│  └─ cloudfront.tf         # CloudFront → S3 Website origin (HTTPS CDN)
└─ scripts/
   └─ refresh-origin-and-cdn.sh  # Optional: makes S3 website + CDN show content now
```

---

## Troubleshooting

**CloudFront URL loads blank / 403 / 404**

* Run the refresh script (enables S3 website, public read policy, uploads files, invalidates cache).
* Confirm `website/index.html` exists and is non-empty.
* Try a private/incognito browser window.

**Wrong bucket/content**

* In the script, make sure `BUCKET` matches the bucket used by the S3 Website endpoint behind CloudFront.

**SSH asks for keys**

* Not required for marking. Only needed if you intend to `git push` back to GitHub.

---

## Footer Credit (on the site)

The deployed site displays:

> **Built by Hardik, Andrea, Daniel, Joseph — 2025 CCA UG**

(Shown in `website/index.html`.)

---

## Well-Architected Alignment (Brief)

* **Security:** Least-privilege IAM for IaC; S3 Website requires object public read by design.
* **Cost Optimisation:** S3 + CloudFront static hosting — no servers.
* **Performance Efficiency:** CDN edge caching + HTTPS.
* **Reliability:** CDN distribution; simple, reproducible Terraform.
* **Operational Excellence:** Clear, automated deploy and refresh; easy teardown.

---

## Notes

* The **CloudFront URL** changes per sandbox session; the helper script is included to avoid waiting for cache and to ensure the S3 website is ready.
* No SSH or GitHub changes are required to mark the deployment.

---
