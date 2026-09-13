# ---------------------------------------------------------------------------
# IAM — rôle dédié au projet, en moindre privilège. Séparé de main.tf pour
# isoler la partie gouvernance/sécurité du reste de l'infrastructure.
# ---------------------------------------------------------------------------

# TODO — data "aws_iam_policy_document" "assume_role" : autorise sts:AssumeRole
# pour un principal de votre propre compte
# (identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"])

data "aws_iam_policy_document" "assume_role" {
    statement {
      actions = ["sts:AssumeRole"]
      principals {
        type = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      }
    }
}

# TODO — resource "aws_iam_role" "pipeline" avec cette assume_role_policy.
# C'est ce rôle que vous assumerez (via `aws sts assume-role`) pour ingérer
# et interroger les données, plutôt que d'utiliser vos identifiants admin.

resource "aws_iam_role" "pipeline" {
  name = "pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# TODO — data "aws_iam_policy_document" "pipeline" : accès scopé à VOTRE
# bucket uniquement —
#   - S3 : List/Get/Put/Delete sur bronze/*, silver/*, gold/*, athena-results/*
#   - Athena : StartQueryExecution, GetQueryExecution, GetQueryResults,
#     StopQueryExecution, GetWorkGroup — sur le workgroup "primary"
#     (arn:aws:athena:<region>:<account_id>:workgroup/primary)
#   - Glue : Get/Create/Update/Delete Table — sur VOTRE base uniquement

data "aws_iam_policy_document" "pipeline" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/bronze/*",
      "arn:aws:s3:::${local.bucket_name}/silver/*",
      "arn:aws:s3:::${local.bucket_name}/gold/*"
    ]
  }
  statement {
    effect = "Allow"

    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetWorkGroup"
    ]

    resources = [
      "arn:aws:athena:${var.aws_region}:${data.aws_caller_identity.current.account_id}:workgroup/primary"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetTable",
      "glue:CreateDatabase",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:DeleteTable"
     ]
     resources = [
      "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${local.glue_database}"
     ]
  }
}

# TODO — resource "aws_iam_role_policy" "pipeline" pour attacher la policy
# ci-dessus au rôle.
resource "aws_iam_role_policy" "pipeline" {
  name = "pipeline-role-policy"
  role = aws_iam_role.pipeline.id
  policy = data.aws_iam_policy_document.pipeline.json
}