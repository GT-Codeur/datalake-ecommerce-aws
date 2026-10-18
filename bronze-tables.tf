resource "aws_glue_catalog_table" "orders" {
  name          = "orders"
  database_name = aws_glue_catalog_database.datalake.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"                       = "csv"
    "skip.header.line.count"               = "1"
    "has_encrypted_data"                   = "false"
    "projection.enabled"                   = "true"
    "projection.ingest_date.type"          = "date"
    "projection.ingest_date.format"        = "yyyy-MM-dd"
    "projection.ingest_date.range"         = "2026-01-01,NOW"
    "projection.ingest_date.interval"      = "1"
    "projection.ingest_date.interval.unit" = "DAYS"
    "storage.location.template"            = "s3://${aws_s3_bucket.datalake.id}/bronze/orders/ingest_date=$${ingest_date}/"
  }

  partition_keys {
    name = "ingest_date"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.datalake.id}/bronze/orders/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "orders-csv-serde"
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"

      parameters = {
        "separatorChar" = ","
        "quoteChar"     = "\""
        "escapeChar"    = "\\"
      }
    }

    columns {
      name = "InvoiceNo"
      type = "string"
    }
    columns {
      name = "ProductID"
      type = "string"
    }
    columns {
      name = "Quantity"
      type = "string"
    }
    columns {
      name = "InvoiceDate"
      type = "string"
    }
    columns {
      name = "UnitPrice"
      type = "string"
    }
    columns {
      name = "CustomerID"
      type = "string"
    }
    columns {
      name = "Country"
      type = "string"
    }
  }
}

resource "aws_glue_catalog_table" "users" {
  name          = "users"
  database_name = aws_glue_catalog_database.datalake.name
  table_type    = "EXTERNAL_TABLE"
  parameters = {
    "classification"                       = "json"
    "has_encrypted_data"                   = "false"
    "projection.enabled"                   = "true"
    "projection.ingest_date.type"          = "date"
    "projection.ingest_date.format"        = "yyyy-MM-dd"
    "projection.ingest_date.range"         = "2026-01-01,NOW"
    "projection.ingest_date.interval"      = "1"
    "projection.ingest_date.interval.unit" = "DAYS"
    "storage.location.template"            = "s3://${aws_s3_bucket.datalake.id}/bronze/users/ingest_date=$${ingest_date}/"
  }

  partition_keys {
    name = "ingest_date"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.datalake.id}/bronze/users/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "user-json-serde"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"

      parameters = {
        "ignore.malformed.json" = "json"
        "case.insensitive"      = "true"
      }
    }

    columns {
      name = "id"
      type = "bigint"
    }
    columns {
      name = "firstname"
      type = "string"
    }
    columns {
      name = "lastname"
      type = "string"
    }
    columns {
      name = "age"
      type = "int"
    }
    columns {
      name = "gender"
      type = "string"
    }
    columns {
      name = "email"
      type = "string"
    }
    columns {
      name = "phone"
      type = "string"
    }
    columns {
      name = "username"
      type = "string"
    }
    columns {
      name = "address"
      type = "struct<address:string,city:string,state:string,statecode:string,postalcode:string,coordinates:struct<lat:double,lng:double>,country:string>"
    }
    columns {
      name = "university"
      type = "string"
    }
    columns {
      name = "company"
      type = "struct<department:string,name:string,title:string,address:struct<address:string,city:string,state:string,statecode:string,postalcode:string,coordinates:struct<lat:double,lng:double>,country:string>>"
    }
    columns {
      name = "role"
      type = "string"
    }
  }
}

resource "aws_glue_catalog_table" "products" {
  name          = "products"
  database_name = aws_glue_catalog_database.datalake.name
  table_type    = "EXTERNAL_TABLE"
  parameters = {
    "classification"                       = "json"
    "has_encrypted_data"                   = "false"
    "projection.enabled"                   = "true"
    "projection.ingest_date.type"          = "date"
    "projection.ingest_date.format"        = "yyyy-MM-dd"
    "projection.ingest_date.range"         = "2026-01-01,NOW"
    "projection.ingest_date.interval"      = "1"
    "projection.ingest_date.interval.unit" = "DAYS"
    "storage.location.template"            = "s3://${aws_s3_bucket.datalake.id}/bronze/products/ingest_date=$${ingest_date}/"
  }

  partition_keys {
    name = "ingest_date"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.datalake.id}/bronze/products/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "product-json-serde"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"

      parameters = {
        "ignore.malformed.json" = "json"
        "case.insensitive"      = "true"
      }
    }

    columns {
      name = "id"
      type = "bigint"
    }
    columns {
      name = "title"
      type = "string"
    }
    columns {
      name = "description"
      type = "string"
    }
    columns {
      name = "category"
      type = "string"
    }
    columns {
      name = "price"
      type = "double"
    }
    columns {
      name = "discountpercentage"
      type = "double"
    }
    columns {
      name = "rating"
      type = "double"
    }
    columns {
      name = "stock"
      type = "int"
    }
    columns {
      name = "tags"
      type = "array<string>"
    }
    columns {
      name = "brand"
      type = "string"
    }
    columns {
      name = "sku"
      type = "string"
    }
    columns {
      name = "weight"
      type = "int"
    }
    columns {
      name = "dimensions"
      type = "struct<width:double,height:double,depth:double>"
    }
    columns {
      name = "warrantyinformation"
      type = "string"
    }
    columns {
      name = "shippinginformation"
      type = "string"
    }
    columns {
      name = "availabilitystatus"
      type = "string"
    }
    columns {
      name = "minimumorderquantity"
      type = "int"
    }
  }
}