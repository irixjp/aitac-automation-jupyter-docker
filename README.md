# AITAC 自動化演習用の Jupyter Notebook コンテナ


## 使い方

```bash
$ docker run -d -p 8888:8888 --name aitac -e PASSWORD=password irixjp/aitac-automation-jupyter:latest
```

- アクセス方法 http://<サーバーのIP>:8888/
- ここで設定したパスワードでログイン可能（ユーザー名は無し）
- ノートブックを外部保存する場合は、 `-v /your-host-dir:/notebooks/hoge` を指定する。/notebooks 配下がデフォルトのワーキングディレクトリとなっている。

