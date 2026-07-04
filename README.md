# php-dev-router

Local HTTPS router for PHP and Laravel projects.

`php-dev-router` discovers PHP apps and static HTML sites in a projects
directory, generates nginx virtual hosts, adds exact local host records to
`/etc/hosts`, and can run as a small systemd watcher so newly added projects
become available automatically.

It is built for development workstations, not production servers.

## Features

- Detects Laravel apps, public front-controller apps, generic PHP apps, and
  static HTML sites.
- Generates HTTPS nginx server blocks, with PHP-FPM routing where needed.
- Maps only detected project hostnames to `127.0.0.1`.
- Avoids wildcard DNS hijacking, so unrelated real domains keep resolving
  normally.
- Supports nested apps such as `monorepo/api`.
- Has no runtime Composer dependencies.

## Requirements

- Linux with systemd
- PHP 8.2 or newer
- nginx
- PHP-FPM for PHP apps
- A local or trusted development certificate/key for the configured domain

The default example config uses `php.test`. Browsers will still require a
certificate trusted by your machine for whatever domain you configure.

## Quick Start

```bash
git clone <repo-url>
cd php-dev-router
cp config.example.json config.json
$EDITOR config.json

./bin/php-dev-router scan
./bin/php-dev-router doctor
sudo ./bin/php-dev-router apply
sudo ./bin/php-dev-router install
```

`install.sh` performs the same install flow and creates `config.json` from the
example if it does not already exist:

```bash
./install.sh
```

## Configuration

Local settings live in `config.json`, which is intentionally ignored by git.
Start from `config.example.json`.

Important options:

- `projects_root`: directory that contains your PHP projects and static sites.
- `domain`: suffix used for generated hostnames.
- `ssl_certificate` / `ssl_certificate_key`: certificate used by nginx.
- `php_fpm_socket`: PHP-FPM socket passed to nginx.
- `nginx_conf`: generated nginx config target.
- `hosts_file`: hosts file target, usually `/etc/hosts`.
- `systemd_service`: watcher service target.

Paths may use `~`.

## Commands

```bash
./bin/php-dev-router scan [--json]
./bin/php-dev-router doctor
./bin/php-dev-router apply [--dry-run] [--no-reload] [--no-nginx-test]
./bin/php-dev-router watch [--interval=3]
./bin/php-dev-router install [--dry-run]
```

Use `apply --dry-run` to review generated nginx and hosts output before writing
system files.

`--no-nginx-test` is intended only for temporary non-root tests. Normal system
installs should let the tool run `nginx -t` before reload.

## Detection Rules

- Laravel app: `artisan` and `public/index.php`, served from `public`.
- Public front-controller app: `public/index.php`, served from `public`.
- Generic PHP app: `index.php`, served from that directory.
- Public static HTML site: `public/index.html` or `public/index.htm`, served
  from `public`.
- Static HTML site: `index.html` or `index.htm`, served from that directory.

Ignored directories include hidden/tooling directories, `vendor`, `node_modules`,
`storage`, and common IDE/cache paths.

## Hostnames

Hostnames are built from the relative project path and the configured domain.
Path parts are joined with hyphens.

Examples for `domain = "php.test"`:

- `billing_admin` -> `billing-admin.php.test`
- `platform/api` -> `platform-api.php.test`

If two projects collide after slugging, a short deterministic hash is appended.

## What Install Writes

`install` writes:

- the generated nginx config from `nginx_conf`
- a managed `php-dev-router` block in `hosts_file`
- the watcher service from `systemd_service`

It then runs `nginx -t`, reloads nginx, enables PHP-FPM/nginx when their systemd
units are available, and enables `php-dev-router.service`.

## Publishing Notes

Do not commit `config.json`; it contains machine-specific paths, domains, and
certificate locations. Commit `config.example.json` instead.
