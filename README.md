# ダウト将棋

正体を隠して駒を打ち、嘘を見破る変則将棋の Web アプリです。王と歩だけを盤に置き、残りの駒は共通の山から引きます。

- ルール: [docs/doubt-shogi-rules.md](docs/doubt-shogi-rules.md)
- 公開手順: [docs/deploy.md](docs/deploy.md)
- 公開先（予定）: https://doubt.enei-shogi.com

## 開発

```bash
cd backend && uv sync && uv run fastapi dev app/main.py
```

```bash
cd frontend && npm install && npm run dev
```

http://localhost:5173 を開きます。
