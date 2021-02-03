#!/bin/bash
set -e

create_log_dir() {
  mkdir -p ${log_dir}
  chown -R 31:31 ${log_dir}
}

create_cache_dir() {
  mkdir -p ${cache_dir}
  chown -R 31:31 ${cache_dir}
}

# allow arguments to be passed to squid
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == squid || ${1} == $(which squid) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch squid
if [[ -z ${1} ]]; then
  create_log_dir
  create_cache_dir
  `which squid` -N -z
  sleep 5
  exec $(which squid) -NYCd 1 ${EXTRA_ARGS}
else
  exec "$(which squid) $@"
fi