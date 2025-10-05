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
