#!/bin/bash
set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes
shopt -s globstar

function verbose () {
  if [[ VERBOSE -eq 1 ]]; then
    echo "${CMD##${KAS_CONFIG_DIR}/}: $1"
  fi
}

function make_dirs() {
  verbose "make_dirs:"
  find ${KAS_CONFIG_DIR} -mindepth 1 -type d -print0 | while IFS= read -r -d '' i
  do
      j=${i##${KAS_CONFIG_DIR}/}
      verbose "    ${j}"
      mkdir -p ${j}
  done
}

function symlink() {
  verbose "symlink:"
  for i in ${KAS_CONFIG_DIR}/**/*.yaml
  do
    j=${i##${KAS_CONFIG_DIR}/}
    verbose "    ${j} -> ${i}"
    ln -sf $i $j
  done
}

function configure() {
  verbose "configure:"
  for i in ${KAS_CONFIG_DIR}/**/*.yaml.in
  do
    j=${i##${KAS_CONFIG_DIR}/}
    j=${j%%.in}
    verbose "    ${i} > ${j}"
    sed -e "s#@@KAS_META_ICS_DM_URL@@#${KAS_META_ICS_DM_URL}#g" \
        -e "s#@@KAS_META_ICS_DM_REFSPEC@@#${KAS_META_ICS_DM_REFSPEC}#g" \
        ${i} > ${j}
  done
}

CMD=$0
verbose KAS_CONFIG_DIR=${KAS_CONFIG_DIR}
verbose YOCTO_BUILD_DIR=${YOCTO_BUILD_DIR}

cd ${YOCTO_BUILD_DIR}

make_dirs ${KAS_CONFIG_DIR}
symlink
configure
rm -rf build/conf
