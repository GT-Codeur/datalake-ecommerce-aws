variable "project_name" {
  description = "Préfixe utilisé pour nommer toutes les ressources du projet"
  type        = string
  default     = "mon-datalake-ecommerce"
}

variable "aws_region" {
  description = "Région AWS de déploiement (choisissez celle la plus proche de vous)"
  type        = string
  default     = "us-east-1"
}

variable "budget_limit_usd" {
  description = "Seuil de l'alerte AWS Budgets (en dollars)"
  type        = number
  default     = 20
}

variable "budget_alert_email" {
  description = "Email qui reçoit l'alerte de dépassement de budget"
  type        = string
}

variable "tags" {
  description = "Tags appliqués à toutes les ressources"
  type        = map(string)
  default = {
    Project = "data-engineering-advanced-datalake-ecommerce"
  }
}
