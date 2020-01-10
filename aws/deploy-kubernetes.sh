#!/bin/bash

source ${PWD}/kops-config/.kops.config.${1}

kops update cluster $NAME \
    --state $KOPS_STATE_STORE \
    --yes
