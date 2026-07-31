# ipt-docker

Docker container for the GBIF IPT, based on the official [gbif/ipt](https://hub.docker.com/r/gbif/ipt) image.

## New instance

Clone this repo into a directory per IPT (e.g. `ipt-docker-nonode`). Edit `docker-compose.yml`
to set a unique `container_name` and host port if needed. Then:

```
chown -R 999:999 iptdata
docker compose up -d
```

Access the IPT at `http://<host>:8080` and complete the setup wizard. The `./iptdata`
directory is mounted at `/srv/ipt` inside the container.

Add a matching `location` block in nginx (proxying to your chosen port)
and set the IPT base URL in Admin → Configuration accordingly.

## Upgrade

Back up, update, fix permissions, rebuild:

```
tar czf iptdata-backup-$(date +%Y%m%d).tar.gz iptdata/
git pull
chown -R 999:999 iptdata/
docker compose build
docker compose up -d
curl -s http://localhost:8080/about | grep -i version
```

Adjust the port in the `curl` command if your instance does not use 8080.

## Host requirements

Configure host swap if running multiple instances on a low-RAM machine. The `memswap_limit`
setting in `docker-compose.yml` only helps when swap is available on the host.

### Memory limits

Each IPT container is configured with the following limits:

- JVM heap: `-Xmx384m` (max), `-Xms128m` (initial)
- JVM metaspace: `-XX:MaxMetaspaceSize=192m`
- Container RAM: `mem_limit: 640m`
- Container RAM + swap: `memswap_limit: 1024m`

These are conservative settings suitable for low-traffic IPT instances. If an IPT serves
larger datasets, sees heavier use, or shows `OOMKilled=true` in `docker inspect`, increase
`-Xmx` and `mem_limit` proportionally (e.g. `-Xmx512m` with `mem_limit: 800m`).

To check whether a container has been OOM-killed:

```
docker inspect <container-name> --format='OOMKilled={{.State.OOMKilled}} RestartCount={{.RestartCount}}'
```
