export PROJECT_ID=cloud-run-487213
export SQLI=run-sql-instance
export REGION=us-central1
export POSTGRES_HOST=cloud-run-ai
export DBNAME=n8n-db-pg
export TIER="db-f1-micro"
export STORAGE_SIZE="10G"
export STORAGE_TYPE="balanced"
export SERVE=n8n-run
export N8N_BASIC_AUTH_USER=jeremygf
export VPCC=n8n-connector
export N8N_HOST=$SERVE
export N8N_PORT=5678

#### Set to true to reinit database
new_db=true
####

gcloud config set project $PROJECT_ID

export N8N_BASIC_AUTH_PASSWORD=$(openssl rand -base64 32) && echo "N8N_BASIC_AUTH_PASSWORD: $N8N_BASIC_AUTH_PASSWORD"

echo -n "$N8N_BASIC_AUTH_PASSWORD" |
	gcloud secrets create N8N_BASIC_AUTH_PASSWORD \
    --replication-policy=automatic
    --data-file=-

export N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)

echo -n "$N8N_ENCRYPTION_KEY" |
	gcloud secrets create N8N_ENCRYPTION_KEY
    --replication-policy=automatic
    --data-file=-

export N8N_DB_PASSWORD=$(openssl rand -base64 32)

echo -n "$N8N_DB_PASSWORD" |
	gcloud secrets create N8N_DB_PASSWORD
    --replication-policy=automatic
    --data-file=-


gcloud iam service-accounts create n8n-sacc --display-name="n8n Service Account"

gcloud secrets add-iam-policy-binding N8N_DB_PASSWORD \
    --member="serviceAccount:n8n-service-account@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding N8N_ENCRYPTION_KEY \
    --member="serviceAccount:n8n-service-account@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding N8N_BASIC_AUTH_PASSWORD \
    --member="serviceAccount:n8n-service-account@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:n8n-service-account@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/cloudsql.client"


# PostGreSDQL database
if [ $new_db = true ]; then
	echo "Deleting database..."
	gcloud sql databases delete $DBNAME -i $SQLI
	echo "Done deleting database"
fi

echo "Creating database..."
gcloud sql instances create $SQLI
    --database-version POSTGRES_13
    --tier $TIER
    --region $REGION
    --root-password $N8N_DB_PASSWORD
    --storage-size $STORAGE_SIZE
    --availability-type ZONAL
    --no-backup
    --storage-type $STORAGE_TYPE
	--set-env-vars DB_POSTGRESDB_SCHEMA=public
	--set-env-vars GENERIC_TIMEZONE=UTC

echo "Creating database and user..."
gcloud sql databases create $DBNAME -i $SQLI
gcloud sql users create $DBNAME -i $SQLI --password=$N8N_DB_PASSWORD

# N8N cloud run
echo "Creating service..."
gcloud run deploy $SERVE
	--image n8nio/n8n:latest
	--command "/bin/sh"
	--args "-c,sleep 5;n8n start"
	--platform managed
	--region $REGION
	--port $N8N_PORT
	--allow-unauthenticated
	--no-cpu-throttling
	--add-cloudsql-instances $SQLI
	--service-account n8n-sacc@$PROJECT_ID.iam.gserviceaccount.com
	--set-env-vars DB_TYPE=postgres
	--set-env-vars DB_POSTGRES_HOST=/cloudsql/$PROJECT_ID:$REGION:$SQLI
	--set-env-vars DB_POSTGRES_PORT=5432
	--set-env-vars DB_POSTGRES_DATABASE=$DBNAME
	--set-env-vars DB_POSTGRES_USER=$DBNAME
	--set-secrets DB_POSTGRESDB_PASSWORD=N8N_DB_PASSWORD:latest
	--set-secrets N8N_ENCRYPTION_KEY=N8N_ENCRYPTION_KEY:latest
	--set-env-vars DB_POSTGRESDB_SCHEMA=public
	--set-env-vars GENERIC_TIMEZONE=UTC
	--set-env-vars N8N_ENDPOINT_HEALTH=health
	--set-env-vars N8N_HEALTHCHECK_ENABLED=true


echo "Running service $SERVE with admin basic auth..."
gcloud run services update $SERVE --region $REGION
	--set-env-vars N8N_BASIC_AUTH_USER=$N8N_BASIC_AUTH_USER
	--set-secrets N8N_BASIC_AUTH_PASSWORD=N8N_BASIC_AUTH_PASSWORD:latest

echo "Updating service with VPC connector..."
gcloud run services update $SERVE --region $REGION --set-vpc-connector $VPCC \
	--update-env-vars N8N_EDITOR_BASE_URL=https://$N8N_HOST
	--update-env-vars N8N_WEBHOOK_URL=https://$N8N_HOST
	--update-env-vars N8N_PUSH_WEBHOOK_URL=https://$N8N_HOST/webhook-push/
	--update-env-vars N8N_HOST=$N8N_HOST
	--update-env-vars N8N_PORT=$N8N_PORT

echo "Creating VPC connector..."
gcloud compute networks vpc-access connectors create $VPCC \
	--region $REGION --network default --range 10.8.0.0/28
