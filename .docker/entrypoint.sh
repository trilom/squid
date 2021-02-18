#!/usr/bin/dumb-init /bin/sh
set -e

create_log_dir() {
  mkdir -p ${SQUID_LOG_DIR}
  chown -R squid:squid ${SQUID_LOG_DIR}
}

create_cache_dir() {
  mkdir -p ${SQUID_CACHE_DIR}
  chown -R squid:squid ${SQUID_CACHE_DIR}
}

create_pid_file() {
  rm -rf /var/run/squid.pid
  touch /var/run/squid.pid
  chown squid:squid /var/run/squid.pid
}

if [ "${1:0:1}" = '-' ]; then
  set -- squid "$@"
fi
if [ "$1" = 'reconfigure' ]; then
  set -- squid -k reconfigure "$@"
fi
if [ "$1" = 'squid' ]; then
  # chown squid:squid /var/run/squid.pid
  # ls -la /var/run/
  create_pid_file
  create_log_dir
  create_cache_dir
  su-exec squid:squid squid -N -z
  set -- su-exec squid:squid "$@"
fi
exec "$@"
