# VuePress Docker 🐳

Univerzální dockerizovaný VuePress pro hot-reload development i produkční build.

## Použití

### Docker Compose (doporučeno)
```bash
cd /c/work/projects/vuepress-docker
docker-compose up --build
```

### Docker Run
```bash
# Build image
docker build -t altisima-vuepress .

# Spuštění s jídelnou
docker run -d \
  -v /c/work/projects/cdn/jidelna:/site:ro \
  -p 8080:8080 \
  -p 9090:9090 \
  --name vuepress-jidelna \
  altisima-vuepress

# Jiný obsah
docker run -d \
  -v /c/work/projects/other-docs:/site:ro \
  -p 8081:8080 \
  -p 9091:9090 \
  --name vuepress-other \
  altisima-vuepress
```

## Porty

- **8080**: Development server s hot reload
- **9090**: Statická produkční verze

## Rebuild produkční verze
```bash
# Rebuild statické verze
docker exec vuepress-jidelna sh -c "cd /site && vuepress build"

# Nebo s aliasem
docker exec vuepress-jidelna rebuild
```

## Logs
```bash
docker logs vuepress-jidelna -f
```

## Stop
```bash
docker-compose down
# nebo
docker stop vuepress-jidelna
```
