# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language

ユーザーへの回答・説明、コミットメッセージは日本語で書く。UI の文言も日本語。

## What this is

ダウト将棋 (Doubt Shogi): a shogi variant web app on the standard 9×9 board. Only the kings and pawns start on the board; the other 20 pieces form a shared hidden pile. Each turn a player draws one, then moves a piece or drops one from a 3-piece hand — and may drop it face down while declaring a different type. The opponent can call ダウト. Captured pieces go to a shared face-up discard pile, not to the captor's hand. The full rules are in `docs/doubt-shogi-rules.md` (v0.1, not yet play-tested).

Status: scaffold only. The backend has `/api/health`, the frontend a placeholder page. Hidden information (pile, hands, the true type of a disguised piece) must stay on the server once a rules engine exists; the client only gets what `docs/doubt-shogi-rules.md` §12 says each player may see.

Sister project: 燕衛将棋 (`D:\enei-shogi`, https://github.com/motomk/enei-shogi). This repository copies its tooling and deployment, and shares its GCP project, Firebase project, tfstate bucket and GitHub Workload Identity pool.

## Commands

Backend (`backend/`, Python 3.13 managed by uv; there is no system Python on this machine — always go through `uv`):

```bash
uv sync
uv run fastapi dev app/main.py   # http://127.0.0.1:8000, docs at /docs
uv run pytest
uvx ruff check .
```

Frontend (`frontend/`, Vite + React 19 + TypeScript):

```bash
npm install
npm run dev     # http://localhost:5173, proxies /api to 127.0.0.1:8000
npm run lint    # oxlint
npm run build   # tsc -b && vite build
```

`.claude/launch.json` has `backend`, `frontend` and `frontend-build` for preview_start.

## Deployment

Not deployed yet (decided 2026-10-25: local development first; `terraform apply` and the Cloudflare DNS record wait until there is something to play). Planned: https://doubt.enei-shogi.com — Firebase Hosting (site `doubt-shogi`) serves `frontend/dist` and rewrites `/api/**` to Cloud Run `doubt-api`. Pushing to main deploys (`.github/workflows/deploy.yml`); infrastructure is `infra/terraform/`, applied by hand. See `docs/deploy.md`.
