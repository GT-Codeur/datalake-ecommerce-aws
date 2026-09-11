# Squelette Terraform de démarrage

Ce dossier n'est **pas** une solution : c'est un point de départ pour le Jour 1
de l'exercice, pour vous éviter de perdre du temps sur la mise en page d'un
projet Terraform plutôt que sur les choix d'architecture eux-mêmes.

## Description et but de chaque fichier

| Fichier | But | Statut |
|---|---|---|
| `main.tf` | Le cœur du provisioning : bucket S3 (le Data Lake), base Glue Data Catalog, AWS Budget, alarme CloudWatch + topic SNS. Tout ce qui n'est pas de la gouvernance/sécurité. | Bloc `terraform{}`/`provider` et plomberie déjà écrits ; ressources en `TODO` |
| `iam.tf` | Le rôle et la policy IAM en moindre privilège, séparés de `main.tf` pour isoler la partie gouvernance/sécurité. C'est ce rôle que vous assumerez (`sts assume-role`) pour ingérer et interroger les données, plutôt que vos identifiants admin. | Entièrement en `TODO` |
| `variables.tf` | Les paramètres réutilisables du projet (nom, région, email d'alerte, budget) — pour ne jamais coder une valeur en dur dans `main.tf`/`iam.tf`. | Déjà écrit |
| `outputs.tf` | Les informations à récupérer après un `terraform apply` (nom du bucket, base Glue, ARN du rôle) — vous vous en servirez ensuite pour l'ingestion et les requêtes Athena. | Déjà écrit |
| `terraform.tfvars` (à créer, non commité) | Vos valeurs concrètes (email, région, budget) — jamais dans le code versionné. | À créer depuis `terraform.tfvars.example` |

## Ce qu'il reste à faire

Remplacer chaque bloc `TODO` dans `main.tf` et `iam.tf` par les ressources
Terraform correspondantes (voir l'énoncé, section 4 "Indices pour démarrer",
pour les noms de ressources et les pièges à éviter). `outputs.tf` suppose que
vous nommez vos ressources `aws_s3_bucket.datalake`,
`aws_glue_catalog_database.datalake` et `aws_iam_role.pipeline` — adaptez les
références si vous choisissez d'autres noms.

**C'est normal que `terraform validate` échoue tant que les TODO ne sont pas
remplacés** — `outputs.tf` et `iam.tf` référencent des ressources qui
n'existent pas encore.

## Démarrer

```bash
cp terraform.tfvars.example terraform.tfvars
# éditer terraform.tfvars : au moins budget_alert_email

terraform init
# ... compléter main.tf puis iam.tf ...
terraform plan
terraform apply
```
# datalake-ecommerce-aws
