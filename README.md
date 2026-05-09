# SchemaSpy

Automated database schema documentation powered by [SchemaSpy](https://schemaspy.org/).  
The project spins up a PostgreSQL database, applies the schema defined in `init/`, and
generates interactive HTML documentation — including entity-relationship diagrams — using
the official SchemaSpy Docker image.

---

## Prerequisites

| Tool | Minimum version |
|------|-----------------|
| [Docker](https://docs.docker.com/get-docker/) | 24+ |
| Docker Compose (plugin or standalone) | v2+ |
| `psql` client *(CI only)* | 15+ |

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/magodeveloper/SchemaSpy.git
cd SchemaSpy

# 2. Generate documentation (starts PostgreSQL, runs SchemaSpy, stops PostgreSQL)
./run-schemaspy.sh

# 3. Open the docs
open output/index.html          # macOS
xdg-open output/index.html      # Linux
```

The generated HTML is written to the `output/` directory (gitignored).

---

## Docker Compose

For a persistent local database you can use Docker Compose directly:

```bash
# Start only the database
docker compose up -d db

# Run SchemaSpy against the running database
docker compose run --rm schemaspy

# Tear everything down (removes volumes)
docker compose down -v
```

---

## Configuration

Edit **`schemaspy.properties`** to change the database connection settings:

| Property | Default | Description |
|----------|---------|-------------|
| `schemaspy.t` | `pgsql` | Database type |
| `schemaspy.host` | `localhost` | Hostname (resolved from inside the container) |
| `schemaspy.port` | `5432` | Database port |
| `schemaspy.db` | `schemaspy` | Database name |
| `schemaspy.u` | `schemaspy` | Database user |
| `schemaspy.p` | `schemaspy` | Database password |
| `schemaspy.o` | `/output` | Output directory inside the container |

All defaults can be overridden via environment variables:

```bash
SCHEMASPY_DB=mydb SCHEMASPY_USER=myuser SCHEMASPY_PASSWORD=secret ./run-schemaspy.sh
```

---

## Adding or Modifying the Schema

SQL files in the `init/` directory are executed in **alphabetical order** when the
PostgreSQL container first starts (or during CI):

```
init/
└── 01_schema.sql   ← add more files here, e.g. 02_seed.sql
```

Changes to any `init/*.sql` file, `schemaspy.properties`, or the workflow definition
automatically trigger a new documentation build in CI.

---

## CI / GitHub Actions

The workflow at `.github/workflows/schemaspy.yml`:

1. Starts a PostgreSQL service container.
2. Applies every SQL file in `init/` to the database.
3. Runs SchemaSpy and uploads the output as an artifact named **`schemaspy-docs`**.
4. On pushes to `master`/`main`, deploys the docs to the **`gh-pages`** branch so they
   are served via GitHub Pages.

### Enabling GitHub Pages

1. Go to **Settings → Pages** in your GitHub repository.
2. Set **Source** to the `gh-pages` branch, root directory.
3. Save — GitHub will publish the docs at `https://<owner>.github.io/<repo>/`.

---

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── schemaspy.yml   # CI workflow
├── init/
│   └── 01_schema.sql       # Sample schema (tables, comments, FK relations)
├── output/                 # Generated docs (gitignored)
├── .gitignore
├── docker-compose.yml      # PostgreSQL + SchemaSpy services
├── run-schemaspy.sh        # Convenience script for local use
├── schemaspy.properties    # SchemaSpy configuration
└── README.md
```

---

## License

This project is released under the [MIT License](LICENSE).
