#!/bin/bash

https://github.com/jupyter/enterprise_gateway/blob/master/etc/docker/nb2kg/start-nb2kg.sh

export NB_PORT=${NB_PORT:-8888}
export GATEWAY_HOST=${GATEWAY_HOST:-localhost}
export KG_URL=${KG_URL:-http://${GATEWAY_HOST}:${NB_PORT}}

#export KG_HTTP_USER=${KG_HTTP_USER:-jovyan}
export KG_HTTP_USER=${JUPYTERHUB_USER:-jovyan}

export KG_REQUEST_TIMEOUT=${KG_REQUEST_TIMEOUT:-30}

#export KERNEL_USERNAME=${KG_HTTP_USER}
export KERNEL_USERNAME=${JUPYTERHUB_USER:-jovyan}

echo "Starting nb2kg against gateway: " ${KG_URL}
echo "Nootbook port: " ${NB_PORT}
echo "Kernel user: " ${KERNEL_USERNAME}

echo "${@: -1}"


exec /usr/local/bin/start-notebook.sh $*
