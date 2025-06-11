#!/bin/sh

# Alias pro rebuild
alias rebuild='cd /site && vuepress build'

# Čekání na mount
while [ ! -f "/site/index.md" ] && [ ! -f "/site/README.md" ]; do
  echo "Waiting for site content to be mounted..."
  sleep 2
done

echo "Site content detected, starting VuePress services..."

# Spuštění VuePress dev serveru na pozadí
cd /site
echo "Starting VuePress dev server on port 8080..."
vuepress dev --port 8080 --host 0.0.0.0 &

# Spuštění build procesu a static serveru
echo "Building static version..."
vuepress build

# Spuštění Express serveru pro statickou verzi
echo "Starting static server on port 9090..."
node /app/static-server.js &

# Udržení kontejneru naživu
wait
