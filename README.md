
# Retail E-Commerce Migration (S3 static site)

Deploys a public static website to Amazon S3 using Terraform (AWS Academy Sandbox friendly).

## How to deploy (one person runs)
1) Launch AWS Academy sandbox → Open AWS Console (Sydney).
2) (If using CloudShell) install Terraform or run locally on your laptop.
3) Clone this repo and run:
   ```bash
   cd terraform
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   
````4. Copy the `website_endpoint` from Terraform output and open it in your browser.

## Destroy

```bash
cd terraform
terraform destroy
```

## Notes

* Update `bucket_name_suffix` in `variables.tf` to make the bucket globally unique.
* Keep repo **private**. Never commit secrets or tfstate files.

## Live demo

CloudFront: [https://d14rlgaavaj9fb.cloudfront.net](https://d14rlgaavaj9fb.cloudfront.net)

---

# Starting a New AWS Sandbox/CloudShell Session (Team Guide)

CloudShell VMs reset between sessions, so do these steps whenever you start a new session. If you’re **brand new** to this repo on your laptop/VM, follow the **first-time** block once, then use the **per-session** quickstart every time after.

## 0) Prereqs (AWS Academy CloudShell)

* Log in to AWS Academy → open **CloudShell** (top-right terminal icon).
* Make sure you’re in the **Sydney** region, or export it in your shell:

  ```bash
  export AWS_REGION=ap-southeast-2
  ```

---

## 1) First-time repo & Git setup (one-time per machine)

> Skip this if you’ve already done it on this CloudShell or your laptop.

```bash
# 1) Clone the repo
git clone https://github.com/hazzymazzy/retail-ecommerce-migration.git
cd retail-ecommerce-migration

# 2) Identify yourself for commits
git config --global user.name  "Your Name"
git config --global user.email "your_uni_email@uni.canberra.edu.au"

# 3) (Recommended) Use SSH with GitHub so you never paste passwords
ssh-keygen -t ed25519 -C "your_uni_email@uni.canberra.edu.au"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub  # Add this to GitHub > Settings > SSH and GPG keys > New SSH key

# 4) Switch this repo’s remote to SSH (only needs to be done once)
git remote set-url origin git@github.com:hazzymazzy/retail-ecommerce-migration.git

# 5) Test SSH auth
ssh -T git@github.com
```

---

## 2) Per-session quickstart (every new CloudShell session)

```bash
cd ~/retail-ecommerce-migration
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

git remote -v              # confirm SSH
ssh -T git@github.com      # expect “Hi hazzymazzy! …”
export AWS_REGION=ap-southeast-2
```

---

## 3) Install Terraform (only if missing)

```bash
sudo yum -y install yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

terraform -version
which terraform
```

---

## 4) Deploy the prototype (S3 + CloudFront via Terraform)

> Our working IaC is **single-file** at `terraform/main.tf`.

```bash
cd ~/retail-ecommerce-migration/terraform

# Clean up old .tf files if needed
rm -f cloudfront.tf outputs.tf s3.tf variables.tf providers.tf

# Ensure website files exist
[ -f ../website/index.html ] || echo "<h1>Retail Store Demo</h1>" > ../website/index.html
[ -f ../website/error.html ] || echo "<h1>404</h1>" > ../website/error.html

terraform init -upgrade
terraform plan -out=tfplan
terraform apply -auto-approve tfplan

# Get public URL
terraform output -raw cloudfront_url
```

---

## 5) Update website content

```bash
nano ../website/index.html
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
```

---

## 6) Clean up (important for shared labs)

```bash
cd ~/retail-ecommerce-migration/terraform
terraform destroy -auto-approve
```

---

## 7) Commit & push changes back to GitHub

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

## 8) Automatically Update the Live Demo URL (CloudFront link)

After a successful Terraform deployment, you can **automatically update** the `## Live demo` section in `README.md` using this helper script.

### Create the script (only once)

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

### Use it (after each successful deployment)

```bash
./scripts/update-readme-url.sh
```

> This ensures everyone always sees the **latest CloudFront demo URL** on GitHub.

---

## Troubleshooting

### `AccessDenied: s3:GetBucketObjectLockConfiguration`

Use the single-file `terraform/main.tf` (old split files cause this).

### `BucketAlreadyExists`

Change the `bucket_name_suffix` in `main.tf` to a unique value.

### `Permission denied (publickey)` on `git push`

Run:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh -T git@github.com
```

### “Duplicate output definition”

Remove leftover split files:

```bash
cd terraform
rm -f cloudfront.tf outputs.tf s3.tf variables.tf
terraform init -upgrade
```

### Terraform confused?

Reset local state (use carefully):

```bash
rm -f terraform.tfstate terraform.tfstate.backup tfplan
terraform init -upgrade
```

---

**All Group Members can follow this README to deploy, update, or destroy the demo app in AWS CloudShell (Sydney region).**


