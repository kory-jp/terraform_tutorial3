# terraform を用いた Lambda の実行

# コンテナ上にて Terraform の実行環境を構築

環境変数を設定

.bashrc, .zshrc にアクセスキーとシークレットアクセスキーの環境変数を設定

```
export AWS_ACCESS_KEY_ID=xxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxx
```

## 初回実行

```
cd infra
terraform init
terraform apply
```

## Lambda との通信

```
curl https://{api_id}.execute-api.{region}.amazonaws.com/dev/hello
```
