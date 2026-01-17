# RosterApp API

Backend service for converting pilot roster images into structured data (JSON) or calendar files (ICS). The app exposes a small REST API and uses OpenAI for OCR + parsing.

## Features
- `POST /api/roster/convert` accepts a JPG/PNG roster image and returns JSON or ICS.
- `GET /api/me` returns authenticated user details.
- `GET /api/hello` and `GET /api/flightz` basic endpoints (mainly for smoke checks).

## API

### Convert roster
`POST /api/roster/convert`  
Content-Type: `multipart/form-data`

Fields:
- `image` (file, required): JPG/PNG roster image
- `format` (string, optional): `json` (default) or `ics`

Response:
- JSON body for `format=json`
- `text/calendar` body for `format=ics`

### Authenticated user
`GET /api/me`  
Requires `Authorization: Bearer <jwt>`

## Configuration
Environment variables (main):
- `OPENAI_API_KEY` (required for OCR/parse)
- `OPENAI_BASE_URL` (optional, default `https://api.openai.com/v1`)
- `OPENAI_OCR_MODEL` (default `gpt-4.1`)
- `OPENAI_PARSE_MODEL` (default `gpt-5.1`)
- `OPENAI_ENABLE_CACHE` (`true` by default; set to `false` to bypass prompt cache)
- `MULTIPART_MAX_FILE_SIZE` (max size per file, bytes)
- `MULTIPART_MAX_REQUEST_SIZE` (max total request size, bytes)
- `CORS_ALLOWED_ORIGINS` (comma-separated)
- `AUTH_ISSUER_URIS` (comma-separated JWT issuers)

Full infrastructure and deployment details are in `README-INFRA.md`.

## Local development

Run the app:
```bash
./gradlew bootRun
```

Run tests:
```bash
./gradlew test
```

Manual OpenAI integration test (calls real API):
```bash
./scripts/run-test-openai-int.sh
```

## Notes
- ICS output follows RFC 5545 line folding and is compatible with Google Calendar.
- If `OPENAI_API_KEY` is missing, the app starts but OpenAI-backed endpoints will fail at runtime.
