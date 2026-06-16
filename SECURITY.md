# Security Policy

`php-dev-router` is intended for local development machines. Do not use it as a
public production vhost manager.

The tool writes nginx, hosts, and systemd files only when explicitly run with
sufficient permissions. Review generated config with:

```bash
./bin/php-dev-router apply --dry-run
```

Please report security issues privately to the repository maintainer instead of
opening a public issue with exploit details.
