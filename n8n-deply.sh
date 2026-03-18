#!/bin/bash
set -e # Exit on any error

export PROJECT_ID=cloud-run-487213
export SQLI=n8n-postgres-instance
export REGION=us-central1
export POSTGRES_HOST=cloud-run-ai
export DBNAME=n8n-db-pg
export TIER="db-f1-micro"
export STORAGE_SIZE="10G"
export STORAGE_TYPE="SSD"
export SERVE=n8n-run
export N8N_BASIC_AUTH_USER=jeremygf
export N8N_PORT=5678
export BUCKET_NAME="n8n-storage-$PROJECT_ID"

#### Set to true to reinit database
new_db=false # Default to false for safety
####

echo "Setting project to $PROJECT_ID..."
gcloud config set project $PROJECT_ID
gcloud services enable sqladmin.googleapis.com run.googleapis.com secretmanager.googleapis.com iam.googleapis.com storage.googleapis.com

# Create secrets if they don't exist, or add new versions
create_or_update_secret() {
    local name=$1
    local value=$2
    if ! gcloud secrets describe "$name" >/dev/null 2>&1; then
        echo "Creating secret $name..."
        echo -n "$value" | gcloud secrets create "$name" --replication-policy=automatic --data-file=-
    else
        echo "Updating secret $name..."
        echo -n "$value" | gcloud secrets versions add "$name" --data-file=-
    fi
}

# IAM Setup
echo "Configuring IAM..."
gcloud iam service-accounts create n8n-run-sacc --display-name="n8n Service Account" --project $PROJECT_ID || true
SACC="n8n-run-sacc@$PROJECT_ID.iam.gserviceaccount.com"

# Grant storage access
gcloud storage buckets add-iam-policy-binding gs://$BUCKET_NAME \
    --member="serviceAccount:$SACC" \
    --role="roles/storage.objectAdmin" --quiet || true

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SACC" \
    --role="roles/cloudsql.client" \
    --quiet

# Database and User setup
gcloud sql databases create $DBNAME -i $SQLI || true

# Initial Deployment
echo "Deploying n8n to Cloud Run..."
gcloud run deploy $SERVE \
    --image n8nio/n8n:latest \
    --command "/bin/sh" \
    --args="-c","sleep 5; n8n start" \
    --platform managed \
    --region $REGION \
    --port $N8N_PORT \
    --allow-unauthenticated \
    --no-cpu-throttling \
    --clear-vpc-connector \
    --add-cloudsql-instances $SQLI \
    --service-account n8n-run-sacc@$PROJECT_ID.iam.gserviceaccount.com \
    --set-env-vars DB_TYPE=postgresdb \
    --set-env-vars DB_POSTGRESDB_HOST=/cloudsql/$PROJECT_ID:$REGION:$SQLI \
    --set-env-vars DB_POSTGRESDB_PORT=5432 \
    --set-env-vars DB_POSTGRESDB_DATABASE=$DBNAME \
    --set-env-vars DB_POSTGRESDB_USER=$DBNAME \
    --set-env-vars DB_POSTGRESDB_SCHEMA=public \
    --set-env-vars GENERIC_TIMEZONE=UTC \
    --set-env-vars N8N_ENDPOINT_HEALTH=health \
    --set-env-vars N8N_HEALTHCHECK_ENABLED=true \
    --set-env-vars N8N_TEMPLATES_ENABLED=true \
    --set-env-vars N8N_BASIC_AUTH_USER=$N8N_BASIC_AUTH_USER \
    --set-env-vars N8N_EXTERNAL_STORAGE_MODE=s3 \
    --set-env-vars N8N_EXTERNAL_STORAGE_S3_BUCKET_NAME=$BUCKET_NAME \
    --set-env-vars N8N_EXTERNAL_STORAGE_S3_REGION=$REGION \
    --set-env-vars N8N_EXTERNAL_STORAGE_S3_ENDPOINT=https://storage.googleapis.com \
    --set-env-vars N8N_EXTERNAL_STORAGE_S3_FORCE_PATH_STYLE=true \
    --set-secrets DB_POSTGRESDB_PASSWORD=N8N_DB_PASSWORD:latest \
    --set-secrets N8N_ENCRYPTION_KEY=N8N_ENCRYPTION_KEY:latest \
    --set-secrets N8N_BASIC_AUTH_PASSWORD=N8N_BASIC_AUTH_PASSWORD:latest \
    --set-secrets N8N_EXTERNAL_STORAGE_S3_ACCESS_KEY_ID=N8N_S3_ACCESS_KEY:latest \
    --set-secrets N8N_EXTERNAL_STORAGE_S3_SECRET_ACCESS_KEY=N8N_S3_SECRET_KEY:latest

# Fetch actual URL to configure n8n correctly
echo "Fetching Service URL..."
SERVICE_URL=$(gcloud run services describe $SERVE --region $REGION --format='value(status.url)')
N8N_HOST=$(echo $SERVICE_URL | sed 's/https:\/\///')

echo "Configuring routing with URL: $SERVICE_URL"
gcloud run services update $SERVE --region $REGION \
    --update-env-vars N8N_EDITOR_BASE_URL=$SERVICE_URL \
    --update-env-vars N8N_WEBHOOK_URL=$SERVICE_URL \
    --update-env-vars N8N_PUSH_WEBHOOK_URL=$SERVICE_URL/webhook-push/ \
    --update-env-vars N8N_HOST=$N8N_HOST

echo "Deployment complete! Access n8n at: $SERVICE_URL"
echo "External Storage configured in gs://$BUCKET_NAME via S3 API"
