set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUCKET="todoapp-local-backups"
ENDPOINT="http://127.0.0.1:4566"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ARCHIVE="todoapp-backup-${TIMESTAMP}.tar.gz"

mkdir -p "$PROJECT_DIR/backups"

echo "Creating Todo application backup..."

tar -czf "$PROJECT_DIR/backups/$ARCHIVE" \
  --exclude='./.git' \
  --exclude='./venv' \
  --exclude='./.venv' \
  --exclude='./__pycache__' \
  --exclude='./.terraform' \
  --exclude='./terraform.tfstate*' \
  --exclude='./backups' \
  --exclude='./.env*' \
  --exclude='./*.pem' \
  -C "$PROJECT_DIR" .

echo "Uploading backup to Floci S3..."

aws --endpoint-url "$ENDPOINT" \
  s3 cp "$PROJECT_DIR/backups/$ARCHIVE" \
  "s3://$BUCKET/$ARCHIVE"

echo "Backup completed successfully!"
echo "File: $ARCHIVE"
