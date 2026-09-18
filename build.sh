#!/usr/bin/env bash
# ddia 静态站构建：克隆上游 → hugo extended 构建 → site/
set -euo pipefail

VERSION="${LAZYCAT_VERSION:-${VERSION:-}}"
echo "==> building ddia version: ${VERSION:-<default branch>}"

rm -rf .upstream public site
if [ -n "$VERSION" ]; then
  if ! git clone --depth 1 --branch "$VERSION" https://github.com/Vonng/ddia.git .upstream 2>/dev/null; then
    echo "==> tag $VERSION not found, falling back to default branch"
    git clone --depth 1 https://github.com/Vonng/ddia.git .upstream
  fi
else
  git clone --depth 1 https://github.com/Vonng/ddia.git .upstream
fi

# hugo extended（模块化主题 oink 需要；模块下载由 hugo 内部调用 go）
HUGO_VERSION="0.166.0"
if ! command -v hugo >/dev/null 2>&1; then
  curl -fsSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz" \
    | tar -xz -C /tmp hugo
  export PATH="/tmp:$PATH"
fi
hugo version

cd .upstream
hugo --minify
cd ..
cp -r .upstream/public site
echo "==> site built: $(du -sh site | cut -f1)"
