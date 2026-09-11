terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# S3 = espace de noms global à tout AWS : ce suffixe aléatoire évite les
# collisions de nom de bucket avec d'autres comptes.
resource "random_id" "suffix" {
  byte_length = 3
}

locals {
  bucket_name   = "${var.project_name}-${random_id.suffix.hex}"
  glue_database = replace("${var.project_name}_${random_id.suffix.hex}", "-", "_")
}

# ---------------------------------------------------------------------------
# TODO 1 — S3 : le Data Lake (bronze / silver / gold / athena-results)
# ---------------------------------------------------------------------------
# - resource "aws_s3_bucket" "datalake" { bucket = local.bucket_name, ... }
#   -> force_destroy = true (sinon `terraform destroy` échouera en fin d'exercice)
#   -> pas besoin de déclarer versioning/chiffrement/blocage d'accès public :
#      un bucket S3 créé aujourd'hui a déjà ces protections par défaut.
# - resource "aws_s3_object" "zones" pour créer les préfixes bronze/, silver/,
#   gold/, athena-results/ (astuce : for_each sur un toset(["bronze/", ...]))

# ---------------------------------------------------------------------------
# TODO 2 — Glue Data Catalog : base logique utilisée par Athena
# ---------------------------------------------------------------------------
# - resource "aws_glue_catalog_database" "datalake" { name = local.glue_database }

# Le rôle IAM en moindre privilège est un fichier à part : voir iam.tf.
# Pas de workgroup Athena dédié à créer : le workgroup "primary" (déjà présent
# par défaut) suffit — chaque requête Athena précisera son propre emplacement
# de résultat (s3://.../athena-results/) au moment de l'appel.

# ---------------------------------------------------------------------------
# TODO 3 — AWS Budgets : alerte de coût sur le projet
# ---------------------------------------------------------------------------
# - resource "aws_budgets_budget" avec au moins un bloc "notification"
#   (comparison_operator, threshold, threshold_type, notification_type,
#   subscriber_email_addresses = [var.budget_alert_email])

# ---------------------------------------------------------------------------
# TODO 4 — SNS + CloudWatch : notification de l'alarme
# ---------------------------------------------------------------------------
# - resource "aws_sns_topic" + resource "aws_sns_topic_subscription"
#   (protocol = "email", endpoint = var.budget_alert_email — nécessitera une
#   confirmation par email avant de fonctionner)
# - resource "aws_cloudwatch_metric_alarm" sur une métrique pertinente
#   (ex. AWS/S3 BucketSizeBytes) avec alarm_actions = [le topic SNS ci-dessus]
