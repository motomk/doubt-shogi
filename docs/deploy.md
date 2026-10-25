# 本番環境への公開（GCP + Terraform）

燕衛将棋（`D:\enei-shogi`）と同じ GCP プロジェクト `portfolio-420211` に、別のサイトと API として載せます。燕衛将棋の Terraform が作ったもの（Firebase プロジェクト、tfstate バケット、GitHub 用 Workload Identity プール、月1,000円の予算アラート）はそのまま共用します。

## 構成

```
ブラウザ ── https://doubt.enei-shogi.com （DNS: Cloudflare の enei-shogi.com ゾーン、プロキシはオフ）
              │
       Firebase Hosting「doubt-shogi」 … frontend/dist を CDN で配信。
              │                         セキュリティヘッダーは frontend/firebase.json
              │ /api/** だけ rewrite
       Cloud Run「doubt-api」（asia-northeast1、1 vCPU / 512 MiB、0〜2台）
              │
       Artifact Registry「doubt」 ← GitHub Actions（Workload Identity、鍵なし）
```

| 何を | どこで管理するか |
| --- | --- |
| Firebase Hosting のサイトと独自ドメイン、Cloud Run の設定、Artifact Registry、サービスアカウントと権限、GitHub 用 Workload Identity のプロバイダー | Terraform（`infra/terraform/`、手で `apply`。tfstate は `gs://portfolio-420211-tfstate` の `doubt-shogi/`） |
| API のイメージ、画面のファイル | GitHub Actions（`.github/workflows/deploy.yml`、main への push で公開） |
| Cloudflare の DNS レコード | Cloudflare の画面で手で登録する |

- 予算アラートは燕衛将棋の Terraform がプロジェクト全体に掛けているので、こちらの費用も同じ予算に数えられます。
- 稼働監視、アクセス数の制限、Turnstile はまだありません。対局の API ができたら燕衛将棋と同じものを足します。

## 最初の1回

gcloud と Terraform のログインは燕衛将棋で済んでいる前提です（`gcloud config get project` が `portfolio-420211`）。

### 1. Terraform で作る

```bash
terraform -chdir=infra/terraform init
```

```bash
terraform -chdir=infra/terraform plan
```

```bash
terraform -chdir=infra/terraform apply
```

サイト ID `doubt-shogi` は `*.web.app` 全体で一意です。ほかの人に取られていて失敗したら、`infra/terraform/variables.tf` の `hosting_site_id` と `frontend/firebase.json` の `site` を同じ別名に変えます。

この時点の Cloud Run は Google のサンプル（hello）が動いています。

### 2. GitHub に Actions の変数を登録する

```bash
gh variable set GCP_WORKLOAD_IDENTITY_PROVIDER --repo motomk/doubt-shogi --body "$(terraform -chdir=infra/terraform output -raw workload_identity_provider)"
```

```bash
gh variable set GCP_DEPLOYER_SERVICE_ACCOUNT --repo motomk/doubt-shogi --body "$(terraform -chdir=infra/terraform output -raw deployer_service_account)"
```

この変数がない間、Deploy ワークフローの公開ジョブはスキップされます。

### 3. main に push して公開する

Deploy が通ったら https://doubt-shogi.web.app が開くか確かめます。

### 4. サブドメインをつなぐ

```bash
terraform -chdir=infra/terraform output dns_records
```

表示されたレコードを、Cloudflare の **enei-shogi.com** ゾーンに、名前 `doubt` で登録します（サブドメインを別に作る操作はなく、レコードを足すだけです）。**プロキシはオフ（灰色の雲）**にしてください。オンのままだと証明書が発行されません。証明書が発行されて https://doubt.enei-shogi.com が開くまで、数十分から数時間かかります。

燕衛将棋の `Strict-Transport-Security` に `includeSubDomains` が付いているので、燕衛将棋を開いたことのあるブラウザでは、このサブドメインも HTTPS でしか開けません。

## ふだんの運用

- コードの変更は、main に入れば自動で公開されます。PR ではテスト（`.github/workflows/ci.yml`）だけが走ります。
- インフラの変更は `infra/terraform/` を書き換え、手で `plan` → `apply` します。
- Cloud Run のイメージ以外の設定は Terraform で変えます。`gcloud run deploy` で直接変えると、次の `apply` で元に戻ります。
