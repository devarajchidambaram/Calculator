# Calculator
Calculator app

## Docker

### Build and run with Docker

```bash
docker build -t calculator-api ./Backend
docker run --rm -p 3000:3000 --name calculator-api calculator-api
```

App runs at `http://localhost:3000` (Swagger at `/docs`).

### Using Docker Compose

From repo root:

```bash
docker compose up --build
```

Stop and remove:

```bash
docker compose down
```

### Environment variables

- `PORT`: container port (default 3000). Update `docker-compose.yml` port mapping if changed.
