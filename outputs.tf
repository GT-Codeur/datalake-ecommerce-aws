# Ces outputs supposent que vous nommez vos ressources comme suggéré dans les
# commentaires de main.tf (ex. aws_s3_bucket "datalake", aws_iam_role "pipeline").
# Si vous choisissez d'autres noms, adaptez les références ci-dessous.

output "bucket_name" {
  description = "Nom du bucket S3 du Data Lake"
  value       = aws_s3_bucket.datalake.id
}

output "glue_database" {
  description = "Nom de la base Glue Data Catalog utilisée par Athena"
  value       = aws_glue_catalog_database.datalake.name
}

output "pipeline_role_arn" {
  description = "ARN du rôle IAM en moindre privilège à assumer pour ingérer/interroger les données"
  value       = aws_iam_role.pipeline.arn
}

output "aws_region" {
  description = "Région AWS utilisée"
  value       = var.aws_region
}
