#!/bin/bash

# Define variables
REPO_URL="https://github.com/abidingnikhil/qloapps.git"
REPO_DIR="qloapps"
DOCKERFILE_PATH="$REPO_DIR/Dockerfile"
REMAKE_DOCKERFILE_PATH="$REPO_DIR/remakeDockerfile"
IMAGE_NAME="qloapps_image"
CONTAINER_NAME="qloapps_container"
VOLUME1_NAME="qloapps_html_volume"
VOLUME2_NAME="qloapps_mysql_volume"
DB_NAME="qloapp_db"
DB_USER="qloapp_user"
DB_PASS="your_strong_password"
PORT_MAPPING="8082:80"

# Clone the repository
git clone "$REPO_URL"

# Check if the repository was cloned successfully
if [ ! -d "$REPO_DIR" ]; then
  echo "Failed to clone repository."
  exit 1
fi

# Ask user for choice
read -p "Do you want a fresh installation of QloApps? (y/n): " choice

# Validate user input
if [[ "$choice" != "y" && "$choice" != "n" ]]; then
  echo "Invalid choice. Please enter 'y' or 'n'."
  exit 1
fi

# Determine which Dockerfile to use
if [ "$choice" == "y" ]; then
  DOCKERFILE="$DOCKERFILE_PATH"
else
  DOCKERFILE="$REMAKE_DOCKERFILE_PATH"
fi

# Build the Docker image
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" "$REPO_DIR"

# Create Docker volumes
docker volume create "$VOLUME1_NAME"
docker volume create "$VOLUME2_NAME"

# Remove the existing container if it exists
docker rm -f "$CONTAINER_NAME" 2>/dev/null

# Run the Docker container
docker run -d \
  --name "$CONTAINER_NAME" \
  -e DB_NAME="$DB_NAME" \
  -e DB_USER="$DB_USER" \
  -e DB_PASS="$DB_PASS" \
  -v "$VOLUME1_NAME:/var/www/html" \
  -v "$VOLUME2_NAME:/var/lib/mysql" \
  -p "$PORT_MAPPING" \
  "$IMAGE_NAME"

echo "Container setup completed."
