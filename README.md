
## begnning_terraform_with_aws

awsでTerraformの勉強

## How to use

Setup credential.

```bash
$ export AWS_ACCESS_KEY_ID="<your access key>"
$ export AWS_SECRET_ACCESS_KEY="your secret access key"
```

Crate resouces.

```bash
$ cd src
$ terraform init
$ terraform plan
$ terraform apply
```

Remove resources.

```bash
$ cd src
$ terraform destroy
```

## Prequirement

- terraform version
    - v1.5.7

- EC2 keypair name
    - aws-kensho