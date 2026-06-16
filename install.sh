#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
if [[ ! -f config.json ]]; then
  cp config.example.json config.json
  echo "Created config.json from config.example.json. Edit it if this machine needs different paths."
fi
sudo -v
sudo ./bin/php-dev-router install
./bin/php-dev-router doctor
