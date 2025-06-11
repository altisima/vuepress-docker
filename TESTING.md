# Testing VuePress Docker 🧪

Tento dokument obsahuje scénáře pro testování všech funkcionalit dockerizovaného VuePress řešení.

## Příprava testovacího prostředí

### Předpoklady

- Docker a Docker Compose nainstalované
- Testovací VuePress obsah (minimálně `index.md` nebo `README.md`)
- Přístup k portům 8080 a 9090

### Testovací struktura

```
/test-content/
├── README.md
├── guide/
│   └── getting-started.md
└── .vuepress/
    └── config.js
```

## Test Scénáře

### 1. Základní funkcionalita

#### 1.1 Docker Build Test

**Účel:** Ověření správného sestavení Docker image

**Kroky:**

1. `cd /c/work/projects/vuepress-docker`
2. `docker build -t altisima-vuepress .`

**Očekávaný výsledek:**

- ✅ Build proběhne bez chyb
- ✅ Image `altisima-vuepress` se vytvoří
- ✅ Velikost image cca 200-300MB

**Kontrola:**

```bash
docker images | grep altisima-vuepress
```

#### 1.2 Docker Compose Start Test

**Účel:** Ověření spuštění přes docker-compose

**Kroky:**

1. `docker-compose up --build`

**Očekávaný výsledek:**

- ✅ Kontejner se spustí
- ✅ Objeví se zpráva "Site content detected, starting VuePress services..."
- ✅ Dev server startuje na portu 8080
- ✅ Static server startuje na portu 9090

### 2. Mounting a Content Detection

#### 2.1 Content Mount Test

**Účel:** Ověření správného namountování obsahu

**Kroky:**

1. Příprava testovacího obsahu v `/test-content/`
2. Úprava `docker-compose.yml`:
   ```yaml
   volumes:
     - /test-content:/site:ro
   ```
3. `docker-compose up --build`

**Očekávaný výsledek:**

- ✅ Kontejner detekuje obsah
- ✅ Čekací smyčka se ukončí
- ✅ VuePress služby se spustí

#### 2.2 Missing Content Test

**Účel:** Ověření chování při chybějícím obsahu

**Kroky:**

1. Mount prázdného adresáře
2. `docker-compose up --build`

**Očekávaný výsledek:**

- ✅ Kontejner čeka s zprávou "Waiting for site content to be mounted..."
- ✅ Po přidání `index.md` nebo `README.md` se služby spustí

### 3. Development Server (Port 8080)

#### 3.1 Dev Server Accessibility Test

**Účel:** Ověření dostupnosti development serveru

**Kroky:**

1. Spuštění kontejneru
2. Otevření `http://localhost:8080`

**Očekávaný výsledek:**

- ✅ Stránka se načte
- ✅ VuePress default theme je viditelný
- ✅ Obsah z mounted adresáře je zobrazen

#### 3.2 Hot Reload Test

**Účel:** Ověření hot reload funkcionality

**Kroky:**

1. Otevření `http://localhost:8080`
2. Úprava `README.md` v mounted adresáři
3. Uložení změn

**Očekávaný výsledek:**

- ✅ Stránka se automaticky znovu načte
- ✅ Změny jsou okamžitě viditelné
- ✅ Žádná chyba v konzoli

#### 3.3 Navigation Test

**Účel:** Ověření navigace mezi stránkami

**Kroky:**

1. Vytvoření více stránek v test obsahu
2. Otevření `http://localhost:8080`
3. Navigace mezi stránkami

**Očekávaný výsledek:**

- ✅ Všechny stránky jsou dostupné
- ✅ SPA routing funguje
- ✅ Rychlé přepínání bez page refresh

### 4. Production Static Server (Port 9090)

#### 4.1 Static Server Accessibility Test

**Účel:** Ověření dostupnosti statického serveru

**Kroky:**

1. Spuštění kontejneru
2. Otevření `http://localhost:9090`

**Očekávaný výsledek:**

- ✅ Stránka se načte
- ✅ Produkční build je zobrazen
- ✅ Gzip komprese je aktivní

#### 4.2 Static Build Content Test

**Účel:** Ověření správnosti statického buildu

**Kroky:**

1. Kontrola buildu: `docker exec [container] ls -la /site/.vuepress/dist/`
2. Otevření `http://localhost:9090`

**Očekávaný výsledek:**

- ✅ Dist adresář obsahuje HTML, CSS, JS soubory
- ✅ Všechny stránky jsou dostupné
- ✅ Assets jsou správně načteny

#### 4.3 SPA Routing Test

**Účel:** Ověření SPA fallback routingu

**Kroky:**

1. Přímé otevření `http://localhost:9090/some/deep/path/`
2. Refresh stránky

**Očekávaný výsledek:**

- ✅ Stránka se načte (fallback na index.html)
- ✅ VuePress router převezme kontrolu
- ✅ Správná stránka se zobrazí

### 5. Rebuild Funkcionalita

#### 5.1 Manual Rebuild Test

**Účel:** Ověření manuálního rebuild procesu

**Kroky:**

1. Spuštění kontejneru
2. Úprava obsahu
3. `docker exec [container] sh -c "cd /site && vuepress build"`
4. Refresh `http://localhost:9090`

**Očekávaný výsledek:**

- ✅ Build proběhne bez chyb
- ✅ Nové změny jsou viditelné na portu 9090
- ✅ Dev server (8080) není ovlivněn

#### 5.2 Rebuild Script Test

**Účel:** Ověření rebuild scriptu

**Kroky:**

1. `docker exec [container] rebuild`

**Očekávaný výsledek:**

- ✅ Zobrazí se "🔄 Starting VuePress build..."
- ✅ Build proběhne
- ✅ Zobrazí se "✅ Build completed!"

#### 5.3 Alias Rebuild Test

**Účel:** Ověření rebuild aliasu

**Kroky:**

1. `docker exec [container] sh -c "rebuild"`

**Očekávaný výsledek:**

- ✅ Alias funguje stejně jako rebuild script

### 6. Multi-instance Testing

#### 6.1 Multiple Containers Test

**Účel:** Ověření možnosti spuštění více instancí

**Kroky:**

1. Spuštění první instance (porty 8080, 9090)
2. Spuštění druhé instance:
   ```bash
   docker run -d \
     -v /other-content:/site:ro \
     -p 8081:8080 \
     -p 9091:9090 \
     --name vuepress-other \
     altisima-vuepress
   ```

**Očekávaný výsledek:**

- ✅ Obě instance běží současně
- ✅ Různý obsah na různých portech
- ✅ Žádné konflikty portů

### 7. Error Handling

#### 7.1 Invalid VuePress Config Test

**Účel:** Ověření chování při neplatné konfiguraci

**Kroky:**

1. Vytvoření chybného `.vuepress/config.js`
2. Spuštění kontejneru

**Očekávaný výsledek:**

- ✅ Chyba je zobrazena v logs
- ✅ Kontejner se nezastaví
- ✅ Po opravě config se služby restartují

#### 7.2 Missing Dependencies Test

**Účel:** Ověření chování při chybějících závislostech

**Kroky:**

1. VuePress obsah s custom plugins
2. Spuštění bez instalace dependencies

**Očekávaný výsleduk:**

- ✅ Chyba je jasně zobrazena
- ✅ Kontejner pokračuje v běhu
- ✅ Možnost doinstalace dependencies

### 8. Performance Testing

#### 8.1 Build Performance Test

**Účel:** Měření rychlosti buildu

**Kroky:**

1. Příprava většího VuePress projektu (50+ stránek)
2. Měření času buildu: `time docker exec [container] rebuild`

**Očekávaný výsledek:**

- ✅ Build dokončen do 2 minut
- ✅ Žádné memory leaky
- ✅ Stabilní výkon při opakovaných buildech

#### 8.2 Memory Usage Test

**Účel:** Kontrola spotřeby paměti

**Kroky:**

1. `docker stats [container]`
2. Sledování po dobu 10 minut

**Očekávaný výsledek:**

- ✅ Stabilní využití RAM (pod 512MB)
- ✅ Žádné memory leaky
- ✅ CPU využití pod 50% v klidovém stavu

### 9. Logging and Monitoring

#### 9.1 Logs Test

**Účel:** Ověření správnosti logování

**Kroky:**

1. `docker logs [container] -f`
2. Provedení různých operací

**Očekávaný výsledek:**

- ✅ Startup sekvence je logována
- ✅ Chyby jsou jasně identifikovatelné
- ✅ Timestamp je přítomen

#### 9.2 Health Check Test

**Účel:** Ověření zdraví služeb

**Kroky:**

1. `curl http://localhost:8080` (dev server)
2. `curl http://localhost:9090` (static server)

**Očekávaný výsledek:**

- ✅ Oba endpointy odpovídají HTTP 200
- ✅ Obsah je vrácen správně
- ✅ Response time pod 1 sekundu

### 10. Cleanup and Restart Testing

#### 10.1 Graceful Shutdown Test

**Účel:** Ověření korektního ukončení

**Kroky:**

1. `docker-compose down`
2. Kontrola ukončení procesů

**Očekávaný výsledek:**

- ✅ Kontejner se ukončí do 10 sekund
- ✅ Žádné "orphaned" procesy
- ✅ Porty jsou uvolněny

#### 10.2 Restart Test

**Účel:** Ověření restartu služeb

**Kroky:**

1. `docker restart [container]`
2. Sledování startup sekvence

**Očekávaný výsledek:**

- ✅ Služby se znovu spustí automaticky
- ✅ Obsah zůstane zachován
- ✅ Konfigurace zůstane neměnná

## Automatizované testování

### Bash Test Script

```bash
#!/bin/bash
# test-runner.sh

echo "🧪 VuePress Docker Test Suite"

# Test 1: Build
echo "Test 1: Docker Build"
docker build -t altisima-vuepress . || exit 1

# Test 2: Basic functionality
echo "Test 2: Basic Start"
docker-compose up -d
sleep 30

# Test 3: Health checks
echo "Test 3: Health Checks"
curl -f http://localhost:8080 || exit 1
curl -f http://localhost:9090 || exit 1

# Test 4: Rebuild
echo "Test 4: Rebuild"
docker exec vuepress-docker_vuepress_1 rebuild || exit 1

# Cleanup
docker-compose down

echo "✅ All tests passed!"
```

## Reportování problémů

Při zjištění problémů zaznamenejte:

- **Prostředí:** OS, Docker verze
- **Kroky k reprodukci**
- **Očekávaný vs skutečný výsledek**
- **Logy:** `docker logs [container]`
- **Systémové informace:** `docker info`

## Checklist pro release

- [ ] Všechny základní testy prošly
- [ ] Multi-instance testování úspešné
- [ ] Performance testy v normálu
- [ ] Error handling funguje správně
- [ ] Dokumentace je aktuální
- [ ] README obsahuje všechny potřebné informace
