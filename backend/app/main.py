import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# The API's own pages (/docs, /openapi.json) on the dev server only: on Cloud
# Run (K_SERVICE) they would be served at the *.run.app URL, which stays open
# for Firebase Hosting
DOCS = not os.environ.get("K_SERVICE")
app = FastAPI(
    title="Doubt Shogi API",
    version="0.1.0",
    docs_url="/docs" if DOCS else None,
    redoc_url="/redoc" if DOCS else None,
    openapi_url="/openapi.json" if DOCS else None,
)

# The Vite dev server proxies /api and production serves the page and the API
# from one origin (Firebase Hosting rewrites /api to Cloud Run), so CORS only
# matters when the frontend is opened from another origin (e.g. `vite preview`).
# DOUBT_CORS_ORIGINS (comma-separated) replaces the localhost defaults.
CORS_ORIGINS = [
    origin.strip()
    for origin in os.environ.get("DOUBT_CORS_ORIGINS", "http://localhost:5173,http://localhost:4173").split(",")
    if origin.strip()
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type", "Authorization"],
)


class Health(BaseModel):
    status: str


@app.get("/api/health")
def health() -> Health:
    return Health(status="ok")
