## WordPress Docker Stack (Local)

Best-practice local stack for WordPress with Nginx, PHP-FPM, MariaDB, and Redis.

### Folder layout
```
wp-stack-local/
├─ .env (not committed; use env.example as a template)
├─ env.example
├─ compose.yml
├─ nginx/
│  ├─ nginx.conf
│  └─ vhost.conf
├─ php/
│  ├─ Dockerfile
│  └─ php.ini
├─ mariadb/
│  └─ conf.d/
│     └─ my.cnf
├─ data/
│  ├─ db/           # database volume (ignored)
│  └─ wp/           # wp-content (ignored)
└─ backup/
   ├─ backup.sh
   └─ restore.sh
```

### Why MariaDB
- Stable, fast, and a great match for WordPress. Long-term maintained (11.4 LTS).
- You can swap to MySQL 8 by replacing the db image and tags if needed.

### Quick start
1) Copy env.example to .env and change secrets:
```
cp env.example .env
```
2) Start services:
```
docker compose pull
docker compose build --no-cache php
docker compose up -d
```
3) Open: http://localhost:8080

### WP-CLI install (optional)
```
docker exec -it wp-php bash -lc '
wp core install \
  --url="$WP_URL" \
  --title="$WP_TITLE" \
  --admin_user="$WP_ADMIN_USER" \
  --admin_password="$WP_ADMIN_PASSWORD" \
  --admin_email="$WP_ADMIN_EMAIL" \
  --skip-email
wp plugin install redis-cache --activate
wp redis enable
'
```

### Backups
```
backup/backup.sh
backup/restore.sh <db.sql> <wp-content.tgz>
```

### Notes
- Nginx serves WordPress from a read-only shared volume `wp-core`; content is writable via `data/wp`.
- WP Cron is disabled and triggered via a dedicated `cron` service.
- Do not commit `.env`, `data/`, or `backup/`.


