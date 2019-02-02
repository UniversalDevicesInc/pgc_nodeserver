#!/bin/bash
docker build --rm -t mynodeserver -f Dockerfile.test .
docker run -it \
  -e PGURL='https://pxu4jgaiue.execute-api.us-east-1.amazonaws.com/test/api/sys/nsgetioturl?params=eyJ1c2VySWQiOiI1NjU0ZmJmMjJlZjNhNzRhN2UwZDg4NTYiLCJpZCI6IjAwOjIxOmI5OjAyOjQ1OjFiIiwicHJvZmlsZU51bSI6MiwicGFzc3dvcmQiOiJ0MVNJaXlmTUluIn0' \
  -e LOCAL=true \
  mynodeserver