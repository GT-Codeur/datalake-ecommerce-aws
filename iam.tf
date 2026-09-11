# ---------------------------------------------------------------------------
# IAM — rôle dédié au projet, en moindre privilège. Séparé de main.tf pour
# isoler la partie gouvernance/sécurité du reste de l'infrastructure.
# ---------------------------------------------------------------------------

# TODO — data "aws_iam_policy_document" "assume_role" : autorise sts:AssumeRole
# pour un principal de votre propre compte
# (identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"])

# TODO — resource "aws_iam_role" "pipeline" avec cette assume_role_policy.
# C'est ce rôle que vous assumerez (via `aws sts assume-role`) pour ingérer
# et interroger les données, plutôt que d'utiliser vos identifiants admin.

# TODO — data "aws_iam_policy_document" "pipeline" : accès scopé à VOTRE
# bucket uniquement —
#   - S3 : List/Get/Put/Delete sur bronze/*, silver/*, gold/*, athena-results/*
#   - Athena : StartQueryExecution, GetQueryExecution, GetQueryResults,
#     StopQueryExecution, GetWorkGroup — sur le workgroup "primary"
#     (arn:aws:athena:<region>:<account_id>:workgroup/primary)
#   - Glue : Get/Create/Update/Delete Table — sur VOTRE base uniquement

# TODO — resource "aws_iam_role_policy" "pipeline" pour attacher la policy
# ci-dessus au rôle.
