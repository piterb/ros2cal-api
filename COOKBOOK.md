# Deployment Cookbook: GCP + Cloud Run + GitHub Actions

Background: small Spring Boot REST API that exposes `/healthz` (health) and `/roster/convert` (sample). Containerized with a multi-stage Dockerfile (Gradle build → distroless Java 17) and configured to read `PORT` for Cloud Run.

Architecture: GitHub Actions builds and tests with Gradle, builds/pushes a Docker image to Artifact Registry, then deploys that image to Cloud Run using Workload Identity Federation (OIDC) instead of long-lived JSON keys.

Stack:
- Java 17 / Spring Boot (REST)
- Gradle build with `bootJar`
- Docker multi-stage → distroless Java 17 base
- Google Cloud Run + Artifact Registry
- GitHub Actions with `google-github-actions/*` actions and WIF

Prerequisites:
- Google Cloud project with billing.
- GitHub repo with branch `main` (workflow trigger).
- Local Docker + Gradle (or rely on CI) if building locally.
- IAM permissions to create Artifact Registry, Service Accounts, WIF pool/provider, and grant roles.

Overview (what you set up):
1) Enable required APIs.
2) Create Artifact Registry (Docker).
3) Create deployer Service Account with least-privilege roles.
4) Create WIF pool/provider for GitHub with repo-bound condition.
5) Bind WIF principal set to the service account (Workload Identity User + Service Account Token Creator).
6) Enable Cloud Run Admin API.
7) Use `.github/workflows/deploy.yml` to build/push/deploy on push to `main`.

## Add PostgreSQL persistence
- Dependencies: add `spring-boot-starter-data-jpa`, Flyway, Postgres driver in `build.gradle` (H2 for tests if you run them).
- Config: set `spring.datasource.url/user/password` via env (e.g., Secret Manager) in `src/main/resources/application.yaml`; keep `spring.jpa.hibernate.ddl-auto=validate`; enable Flyway.
- Entities: create JPA entities under `src/main/java/com/ryr/ros2cal_api/<feature>/` with matching repositories and services; expose controllers that write/read via repositories.
- Migration: create DDL in `src/main/resources/db/migration/Vx__*.sql` so Flyway creates tables; align columns with entities.
- Docker/Cloud Run: image built by `Dockerfile`; Cloud Run uses env vars for DB (no baked-in secrets).
- CI: `.github/workflows/deploy.yml` builds/pushes/deploys; adjust envs for DB secrets or set `SKIP_TESTS` as needed.

Example entity (trim to your domain):
```java
@Entity
@Table(name = "sample")
public class Sample {
    @Id
    @Column(nullable = false, updatable = false)
    private UUID id;

    @Column(nullable = false, length = 255)
    private String message;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
```

Parts to touch when adding a new table/feature:
- `build.gradle`: ensure JPA/Flyway/Postgres dependencies are present.
- `src/main/resources/application.yaml`: datasource env keys, `ddl-auto: validate`, Flyway enabled.
- `src/main/resources/db/migration/`: new Flyway migration for the table.
- `src/main/java/...`: entity + repository + service + controller exposing the endpoint.
- `Dockerfile`: no change, but ensure DB envs are supplied at runtime.
- `.github/workflows/deploy.yml`: set env or secrets for DB connection if deploying via GitHub Actions.

### Secrets and Cloud Run env
- Enable Secret Manager; add secrets for DB URL/user/password.
- Grant `Secret Manager Secret Accessor` to the Cloud Run runtime service account (project-number SA).
- In Cloud Run → Edit and deploy new revision → set env vars and attach secrets to them (e.g., `DB_URL`, `DB_USER`, `DB_PASS`).

### Handy commands
- Run with env file: `docker run --rm -p 8080:8080 --env-file .env -e PORT=8080 -e SPRING_DATASOURCE_URL=jdbc:h2:mem:test <image>`
- Inspect container env: `docker inspect <NAME> --format '{{range .Config.Env}}{{println .}}{{end}}'`
- Quick DNS check from container: `docker run --rm alpine sh -lc "apk add --no-cache bind-tools >/dev/null && nslookup <HOST>"`

## 1) Initial setup
- Create a project and link it to a billing account.
- Enable APIs: Artifact Registry API, Cloud Resource Manager API, IAM Service Account Credentials API.

## 2) Artifact Registry (Docker)
- Format: Docker, Mode: Standard.
- Location: e.g., `europe-west3` (lower latency in Europe).
- Immutable tags: off (for development).
- Retention policies: keep last 3 images and delete after 1h (for dev/lab).

## 3) Service Account for deploy
- IAM & Admin → Service Accounts → Create.
- Name: `gha-cloudrun-deployer` (ID can stay automatic).
- Grant roles: Cloud Run Admin (`roles/run.admin`), Artifact Registry Writer (`roles/artifactregistry.writer`), Service Account User (`roles/iam.serviceAccountUser`), Secret Manager Admin (`roles/secretmanager.admin`)

## 4) WIF provider for GitHub
- Create a Workload Identity Pool, e.g., `github-pool`, provider type OIDC.
- Provider details: GitHub, issuer URL: `https://token.actions.githubusercontent.com`, audiences: default.
- Attributes: `google.subject => assertion.sub`, `attribute.repository => assertion.repository`.
- Condition: `assertion.repository == "YOUR_OWNER/YOUR_REPO"`.
- PrincipalSet URL to use in IAM (UI hides it):  
  `principalSet://iam.googleapis.com/projects/878047055552/locations/global/workloadIdentityPools/github-pool/attribute.repository/YOUR_OWNER/YOUR_REPO`

## 5) Link WIF ↔ Service Account
- In the WIF page, copy the IAM Principal name (or use the PrincipalSet URL above).
- In IAM & Admin → Service Accounts → pick `gha-cloudrun-deployer` → Grant Access.
- Paste the principal and assign roles: Workload Identity User + Service Account Token Creator.  
  (If using the principal set URL, replace `YOUR_OWNER/YOUR_REPO` appropriately.)

## 6) Enable Cloud Run Admin API
- Enable the API, otherwise deploy will fail.

## 7) GitHub Actions deploy pipeline
- Workflow is in `.github/workflows/deploy.yml`.
- Check/fill env values (project, region, Cloud Run service name, Artifact Registry repo, WIF provider, service account email, image name). Defaults in the repo:
  - `GCP_PROJECT_ID`: `ros2cal-481314`
  - `GCP_REGION`: `europe-west3`
  - `CLOUD_RUN_SERVICE`: `ros2cal`
  - `ARTIFACT_REPO`: `lab`
  - `WIF_PROVIDER`: `projects/878047055552/locations/global/workloadIdentityPools/github-pool/providers/github`
  - `GCP_SA_EMAIL`: `gha-cloudrun-deployer@ros2cal-481314.iam.gserviceaccount.com`
  - `IMAGE_NAME`: `ros2cal`
- Workflow steps: OIDC auth, `gcloud` setup, Docker auth to Artifact Registry, `./gradlew test`, build & push Docker image, deploy to Cloud Run with `--allow-unauthenticated` (remove for private).
- Trigger: push to `main`.

### Notes
- App reads `PORT` from env (`server.port: ${PORT:8080}`) and exposes `GET /healthz` for Cloud Run health checks.
- For stricter/production use, enable immutable tags and adjust retention in Artifact Registry.
