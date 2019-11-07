# AITAC インフラ自動化演習用 Jupyter Lab コンテナ


## 使い方

```bash
$ docker run -d -p 8888:8888 --name aitac -e PASSWORD=password irixjp/aitac-automation-jupyter:latest
```

- アクセス方法 http://<サーバーのIP>:8888/
- ここで設定したパスワードでログイン可能（ユーザー名は無し）

