#!/bin/bash

# 1. LOAD CONFIGURATION
# We use 'set -a' to automatically export variables defined in .env
if [ -f .env ]; then
    set -a
    source .env
    set +a
else
    echo "❌ Error: .env file not found!"
    echo "   Please create a .env file with DOMAIN and EMAIL variables."
    exit 1
fi

# Verify variables exist
if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "❌ Error: DOMAIN or EMAIL is missing in .env file."
    exit 1
fi

echo "============================================"
echo " 🚀 STARTING LLM SERVER SETUP"
echo " 🌍 Domain: $DOMAIN"
echo " 📧 Email:  $EMAIL"
echo "============================================"

# 2. GENERATE NGINX CONFIG FROM TEMPLATE
echo "🔧 Generating nginx.conf..."
if [ -f nginx/nginx.conf.template ]; then
    # We use sed to replace ${DOMAIN} in the template with the actual value
    sed "s/\${DOMAIN}/$DOMAIN/g" nginx/nginx.conf.template > nginx/nginx.conf
    echo "✅ nginx.conf generated."
else
    echo "❌ Error: nginx/nginx.conf.template not found!"
    exit 1
fi

# 3. SET DNS TO GOOGLE (8.8.8.8)
echo "🔧 Configuring DNS..."
if ! grep -q "8.8.8.8" /etc/resolv.conf; then
    cp /etc/resolv.conf /etc/resolv.conf.bak
    sed -i '1s/^/nameserver 8.8.8.8\n/' /etc/resolv.conf
    echo "✅ DNS updated to 8.8.8.8."
else
    echo "✅ DNS already correct."
fi

# 4. CERTIFICATE CHECK & GENERATION
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"

if [ -f "$CERT_PATH" ]; then
    echo "✅ SSL Certificate exists. Skipping generation."
else
    echo "⚠️  Certificate not found. Generating new SSL Cert..."
    
    # Ensure port 80 is free
    docker stop llm-nginx > /dev/null 2>&1
    docker rm llm-nginx > /dev/null 2>&1

    # Run Standalone Certbot
    # Note: If this fails with timeout, ensure Port 80 is open in Security Groups
    docker run -it --rm --name temp-certbot \
      -v /etc/letsencrypt:/etc/letsencrypt \
      -v /var/lib/letsencrypt:/var/lib/letsencrypt \
      -p 80:80 \
      certbot/certbot certonly --standalone \
      -d "$DOMAIN" \
      --email "$EMAIL" \
      --agree-tos --no-eff-email

    if [ -f "$CERT_PATH" ]; then
        echo "✅ Certificate generated successfully!"
    else
        echo "❌ Certificate generation FAILED."
        echo "👉 Check Huawei Cloud Security Group: Port 80 must be open."
        exit 1
    fi
fi

# 5. START DOCKER STACK
echo "🐳 Starting Docker Services..."
docker compose up -d

# 6. DOWNLOAD MODELS
echo "⏳ Waiting for Ollama to initialize (10s)..."
sleep 10

# Split the MODELS string into an array based on spaces
IFS=' ' read -r -a MODEL_ARRAY <<< "$MODELS"

for model in "${MODEL_ARRAY[@]}"; do
    echo "📥 Pulling Model: $model ..."
    # We ignore errors here in case the model is already pulled
    docker exec llm-ollama ollama pull "$model" || echo "⚠️  Could not pull $model (might already exist or name is wrong)"
done

echo "============================================"
echo " 🎉 SETUP COMPLETE!"
echo " 🌍 API Endpoint: https://$DOMAIN/v1"
echo "============================================"
