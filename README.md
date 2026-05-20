# ipt-docker

Docker container for the GBIF IPT.

## How to

```
docker-compose up -d
```

Then access IPT installation page using the host's IP address and port 8080. The `./iptdata` directory is mounted as a volume and used as the IPT data directory.

## Host requirements

This deployment assumes the host meets a few requirements beyond
having Docker installed. The compose configuration includes memory
limits and a `memswap_limit` setting that depend on host-level swap
being available.

### Recommended host specifications

- At least 4 GB RAM for running multiple IPT containers comfortably.
  A 2 GB host can work but may require swap (see below)

### Swap configuration

The `memswap_limit` setting in `docker-compose.yml` allows containers
to spill cold memory pages into host swap when under RAM pressure.
This is meaningless unless swap is actually configured on the host.

_If the host has no swap configured, the `memswap_limit` setting is
effectively null. Containers will still be bounded by `mem_limit`,
but will be OOM-killed under memory pressure rather than spilling
into swap. The deployment will run, but with reduced resilience._

To create a 4 GB swap file on a host without one:

```
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```
Verify it's active:

```
free -h
```

The `Swap` line should show 4.0Gi total.

For a JVM-heavy server, also lower swappiness so the kernel prefers
keeping things in RAM:

```
sysctl vm.swappiness=10
echo 'vm.swappiness=10' >> /etc/sysctl.conf
```

### Memory limits

Each IPT container is configured with the following limits:

- JVM heap: `-Xmx384m` (max), `-Xms128m` (initial)
- JVM metaspace: `-XX:MaxMetaspaceSize=192m`
- Container RAM: `mem_limit: 640m`
- Container RAM + swap: `memswap_limit: 1024m`

These are conservative settings suitable for low-traffic IPT
instances. If an IPT serves larger datasets, sees heavier use, or
shows `OOMKilled=true` in `docker inspect`, increase `-Xmx` and
`mem_limit` proportionally (e.g. `-Xmx512m` with `mem_limit: 800m`).

To check whether a container has been OOM-killed:

```
docker inspect <container-name> --format='OOMKilled={{.State.OOMKilled}} RestartCount={{.RestartCount}}'
```

### Background

These settings were introduced after an incident on 2026-05-20 in
which four IPT containers running on a 1.9 GB host without swap
exhausted available RAM. Without explicit limits, a single
JVM under pressure could claim enough memory to destabilise the
entire host.

The `restart: unless-stopped` policy on each container ensures
automatic recovery from crashes or host reboots while still
allowing deliberate manual stops for maintenance.
