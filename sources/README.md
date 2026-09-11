# Sources — Exercice Data Lake E-commerce

## `bronze_csv/orders.csv`
Export "ERP" des commandes (format inspiré du dataset Online Retail). Colonnes :
`InvoiceNo, ProductID, Quantity, InvoiceDate, UnitPrice, CustomerID, Country`

- `InvoiceNo` préfixé `C` = commande annulée / retour (`Quantity` négative).
- `ProductID` référence l'`id` de `products.jsonl`.
- `CustomerID` référence l'`id` de `users.jsonl`.
- Ce fichier contient des anomalies volontaires (doublons, valeurs manquantes,
  identifiants orphelins, pays mal formatés, dates invalides, prix aberrants).
  Il n'y a pas de liste "officielle" fournie aux participants : la détection
  fait partie de l'exercice (cf. étape contrôle qualité).

## `bronze_json/products.jsonl`
Catalogue produit (source applicative), un objet JSON par ligne (NDJSON — format
attendu par le SerDe JSON d'Athena). Structure imbriquée : `dimensions` (objet),
`tags` (tableau). 100 produits.

## `bronze_json/users.jsonl`
Clients (source applicative), NDJSON, 100 utilisateurs. Structure imbriquée :
`address` (objet, avec `coordinates` imbriqué), `company` (objet, avec sa propre
`address` imbriquée). Champs sensibles (mot de passe, IBAN, SSN, etc.) déjà retirés.