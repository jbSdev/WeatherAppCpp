# weather-api

A minimal C++ HTTP service that returns current weather for Warsaw via the OpenWeatherMap API.

**Stack:** Crow (HTTP) · libcurl · nlohmann/json · CMake · Docker · Jenkins

---

## Endpoints

| Method | Path       | Description                        |
|--------|------------|------------------------------------|
| GET    | `/weather` | Current weather in Warsaw          |
| GET    | `/health`  | Health check, always returns `200` |

### Example response — `/weather`

```json
{
  "city": "Warsaw",
  "country": "PL",
  "temperature": 18.4,
  "feels_like": 17.1,
  "humidity": 62,
  "description": "scattered clouds",
  "wind_speed": 4.1
}
```

---

## Prerequisites

- OpenWeatherMap API key (free tier is enough) → https://openweathermap.org/api
- Docker on the homelab server
- Jenkins running on the homelab (see below)
- GitHub repository with a webhook pointing to Jenkins

---

## Local build (optional)

```bash
sudo apt install build-essential cmake libcurl4-openssl-dev

cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel

OWM_API_KEY=your_key ./build/weather-api
curl http://localhost:8080/weather
```

---

## Homelab: start Jenkins

```bash
cd jenkins/
docker compose up -d

# Get the initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Open http://\<homelab-ip\>:8081, paste the password, and install the **suggested plugins**.

---

## Jenkins setup (one-time)

### 1. Install the Docker plugin

Dashboard → Manage Jenkins → Plugins → Available → search **Docker** → install.

### 2. Store the OpenWeatherMap API key

Dashboard → Manage Jenkins → Credentials → System → Global credentials → **Add Credential**

| Field | Value |
|-------|-------|
| Kind | Secret text |
| Secret | `<your OWM key>` |
| ID | `owm-api-key` |

### 3. Create the Pipeline job

1. New Item → name it `weather-api` → **Pipeline**
2. Under *Build Triggers*, check **GitHub hook trigger for GITScm polling**
3. Under *Pipeline*, choose **Pipeline script from SCM**
   - SCM: Git
   - Repository URL: your GitHub repo URL
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
4. Save

### 4. Add the GitHub webhook

In your GitHub repo → Settings → Webhooks → Add webhook

| Field | Value |
|-------|-------|
| Payload URL | `http://<homelab-ip>:8081/github-webhook/` |
| Content type | `application/json` |
| Which events | Just the **push** event |

> If your homelab isn't publicly reachable, use **ngrok** or a VPN (e.g. Tailscale) to expose Jenkins. With Tailscale the URL is `http://<tailscale-ip>:8081/github-webhook/`.

---

## Pipeline stages

```
Checkout → Build Docker Image → Smoke Test → Deploy → Verify Deployment
```

Every push to `main` triggers this flow automatically. The container runs with `--restart unless-stopped`, so it survives server reboots.

---

## Access the running service

```bash
curl http://<homelab-ip>:8080/weather
```
