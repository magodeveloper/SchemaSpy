#!/usr/bin/env bash
# run-schemaspy.sh — Generate SchemaSpy database documentation locally
#
# Usage:
#   ./run-schemaspy.sh           # spin up PostgreSQL + SchemaSpy, then clean up
#   ./run-schemaspy.sh --no-db   # run SchemaSpy against an already-running database

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration (override via environment variables)
# ---------------------------------------------------------------------------
SCHEMASPY_DB="${SCHEMASPY_DB:-schemaspy}"
SCHEMASPY_USER="${SCHEMASPY_USER:-schemaspy}"
SCHEMASPY_PASSWORD="${SCHEMASPY_PASSWORD:-schemaspy}"
SCHEMASPY_HOST="${SCHEMASPY_HOST:-localhost}"
SCHEMASPY_PORT="${SCHEMASPY_PORT:-5432}"

OUTPUT_DIR="$(pwd)/output"
NO_DB=false

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    --no-db) NO_DB=true ;;
    -h|--help)
      echo "Usage: $0 [--no-db]"
      echo ""
      echo "Options:"
      echo "  --no-db   Skip starting a local PostgreSQL container."
      echo "            Use this when you already have a running database."
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()  { echo "[INFO]  $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

require_command() {
  command -v "$1" >/dev/null 2>&1 || error "'$1' is required but not installed."
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
require_command docker

if [[ "$NO_DB" == false ]]; then
  # Prefer docker compose (v2 plugin) over legacy docker-compose
  if docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
  elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
  else
    error "Neither 'docker compose' nor 'docker-compose' is available."
  fi
fi

# ---------------------------------------------------------------------------
# Prepare output directory
# ---------------------------------------------------------------------------
mkdir -p "$OUTPUT_DIR"
info "Output directory: $OUTPUT_DIR"

# ---------------------------------------------------------------------------
# Start PostgreSQL (unless --no-db is set)
# ---------------------------------------------------------------------------
if [[ "$NO_DB" == false ]]; then
  info "Starting PostgreSQL and waiting for it to be healthy …"
  export SCHEMASPY_DB SCHEMASPY_USER SCHEMASPY_PASSWORD SCHEMASPY_HOST SCHEMASPY_PORT
  $COMPOSE_CMD up -d db

  info "Waiting for PostgreSQL to be ready …"
  until docker exec schemaspy-db pg_isready -U "$SCHEMASPY_USER" >/dev/null 2>&1; do
    sleep 1
  done
  info "PostgreSQL is ready."
fi

# ---------------------------------------------------------------------------
# Run SchemaSpy
# ---------------------------------------------------------------------------
info "Running SchemaSpy …"

docker run --rm \
  --network="$(basename "$(pwd)")_default" \
  -v "$OUTPUT_DIR:/output" \
  -v "$(pwd)/schemaspy.properties:/schemaspy.properties" \
  schemaspy/schemaspy:latest \
  -configFile /schemaspy.properties \
  -host "${SCHEMASPY_HOST}" \
  -port "${SCHEMASPY_PORT}" \
  -db  "${SCHEMASPY_DB}" \
  -u   "${SCHEMASPY_USER}" \
  -p   "${SCHEMASPY_PASSWORD}" \
  -o   /output

info "Documentation generated in: $OUTPUT_DIR"
info "Open $OUTPUT_DIR/index.html in your browser to view it."

# ---------------------------------------------------------------------------
# Tear down (unless --no-db is set)
# ---------------------------------------------------------------------------
if [[ "$NO_DB" == false ]]; then
  info "Stopping PostgreSQL …"
  $COMPOSE_CMD down -v
fi
