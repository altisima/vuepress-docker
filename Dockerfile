FROM node:18-alpine

# Pracovní adresář
WORKDIR /app

# Globální VuePress instalace
RUN npm install -g vuepress@1.9.7

# Vytvoření site adresáře pro mount
RUN mkdir -p /site

# Package.json pro VuePress závislosti
COPY package.json ./
RUN npm install

# Startup script, static server a rebuild script
COPY entrypoint.sh ./
COPY static-server.js ./
COPY rebuild.sh ./
RUN chmod +x entrypoint.sh rebuild.sh

# Expose porty
EXPOSE 8080 9090

# Výchozí command
CMD ["./entrypoint.sh"]
