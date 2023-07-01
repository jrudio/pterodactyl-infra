## Deprecation

The startup scripts, mysql configuration, and redis configuration files are deprecated as GCE VM is no longer used in favor of Cloud SQL. Keeping the files here just in case.

init.sql is relevant

## Cloud SQL

- Toss init.sql into a Cloud Storage bucket
- Give the google-owned Cloud SQL service account Storage Admin or Storage Object Reader role onto the bucket:

> gsutil iam ch serviceAccount:<service-account-id>@gcp-sa-cloud-sql.iam.gserviceaccount.com:objectAdmin \
    gs://<bucket-name>

- Run init.sql on the database:

> gcloud sql import sql <database-instance-name> gs://<bucket-name>/init.sql \
    --database=pterodactyl-ui-db

[1] https://cloud.google.com/sql/docs/mysql/import-export/import-export-sql#gcloud_1