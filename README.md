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
   ```
4) Copy the `website_endpoint` from Terraform output and open it in your browser.

## Destroy
```bash
cd terraform
terraform destroy
```

## Notes
- Update `bucket_name_suffix` in `variables.tf` to make the bucket globally unique.
- Keep repo **private**. Never commit secrets or tfstate files.

## Live demo
CloudFront: https://d1hpky7ifu9ucz.cloudfront.net


 Awesome idea. Here’s a drop-in README section you can paste into your repo. It’s written for AWS Academy CloudShell (ephemeral VMs) and covers both **first-time** setup and **every session** steps, plus deploy/teardown and quick fixes.

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
#    a) Generate a new SSH key (press Enter for all prompts)
ssh-keygen -t ed25519 -C "your_uni_email@uni.canberra.edu.au"

#    b) Start agent & add your key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

#    c) Copy your public key and add it at: GitHub > Settings > SSH and GPG keys > New SSH key
cat ~/.ssh/id_ed25519.pub

#    d) Switch this repo’s remote to SSH (only needs to be done once)
git remote set-url origin git@github.com:hazzymazzy/retail-ecommerce-migration.git

#    e) Test SSH auth (expect “Hi <username>! …”)
ssh -T git@github.com
```

> **Alternative (not recommended):** HTTPS + Personal Access Token (PAT). If you must: create a PAT on GitHub with `repo` scope and use it as the password when `git push` prompts.

---

## 2) Per-session quickstart (every new CloudShell session)

```bash
# Enter the repo
cd ~/retail-ecommerce-migration

# Start SSH agent and load your key (CloudShell forgets between sessions)
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Sanity checks
git remote -v              # should show git@github.com:hazzymazzy/retail-ecommerce-migration.git
ssh -T git@github.com      # should say “Hi <you>! …”
export AWS_REGION=ap-southeast-2
```

---

## 3) Install Terraform (only if `terraform` isn’t found)

```bash
# Add HashiCorp repo and install Terraform (Amazon Linux / CloudShell)
sudo yum -y install yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

terraform -version
which terraform
```

---

## 4) Deploy the prototype (S3 + CloudFront via Terraform)

> Our working IaC is **single-file** at `terraform/main.tf`. It creates a **private** S3 bucket and serves it via **CloudFront OAC**.

```bash
cd ~/retail-ecommerce-migration/terraform

# Make sure only main.tf exists (avoids duplicate outputs/conflicts)
ls -1 *.tf
# If you see old split files (cloudfront.tf/outputs.tf/s3.tf/variables.tf), delete them:
# rm -f cloudfront.tf outputs.tf s3.tf variables.tf

# Ensure website files exist (they’re in ../website)
[ -f ../website/index.html ] || echo "<h1>Retail Store Demo</h1>" > ../website/index.html
[ -f ../website/error.html ] || echo "<h1>404</h1>" > ../website/error.html

# Init & plan
terraform init -upgrade
terraform plan -out=tfplan

# Apply (creates bucket, uploads files, makes the CloudFront distribution)
terraform apply -auto-approve tfplan

# Get the public URL
terraform output -raw cloudfront_url
```

> **Note:** CloudFront takes ~2–4 minutes to deploy after `apply`.

### Bucket name uniqueness

By default the bucket name suffix is set inside `main.tf` under `variable "bucket_name_suffix"`.
If `terraform apply` fails with **BucketAlreadyExists**, edit the default to something unique (e.g., your initials + random), then re-`init/plan/apply`.

---

## 5) Update website content

```bash
# Edit the site content
nano ../website/index.html

# Re-upload happens automatically on next `terraform apply`
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
```

---

## 6) Clean up (important for shared labs)

When you’re done, destroy to avoid extra resources lingering:

```bash
cd ~/retail-ecommerce-migration/terraform
terraform destroy -auto-approve
```

---

## 7) Commit & push changes back to GitHub

```bash
cd ~/retail-ecommerce-migration

# Make sure we don’t commit local state/plan files
# (Already in .gitignore, but just in case)
printf '%s\n' \
'.terraform/' '.terraform.lock.hcl' \
'terraform.tfstate' 'terraform.tfstate.backup' '*.tfstate*' \
'crash.log' '*.tfplan' \
'.DS_Store' 'Thumbs.db' >> .gitignore

git add -A
git commit -m "Update site / Terraform config"
git push origin main
```

---

## Troubleshooting

### `AccessDenied: s3:GetBucketObjectLockConfiguration`

* You’re on restrictive Academy IAM policies. Our config **creates the S3 bucket via CLI** in `null_resource` to avoid that read. Make sure you’re using the provided `main.tf` (single file) and not the older split files.

### `BucketAlreadyExists`

* Change `bucket_name_suffix` in `main.tf` to a unique value, then `terraform init -upgrade && terraform apply` again.

### `Permission denied (publickey)` on `git push`

* You’re in a fresh CloudShell. Run:

  ```bash
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
  ssh -T git@github.com
  ```
* Confirm the repo remote is SSH:

  ```bash
  git remote -v
  # if not SSH, run:
  git remote set-url origin git@github.com:hazzymazzy/retail-ecommerce-migration.git
  ```

### “Duplicate output definition”

* Delete leftover files:

  ```bash
  cd terraform
  rm -f cloudfront.tf outputs.tf s3.tf variables.tf
  terraform init -upgrade
  ```

### Terraform stuck or confused?

* Nuke local state **only if necessary** (this deletes local state; use with care):

  ```bash
  rm -f terraform.tfstate terraform.tfstate.backup tfplan
  terraform init -upgrade
  ```

---


